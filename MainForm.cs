using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace MicroMachinesEditor
{
    public partial class MainForm : Form
    {
        public MainForm()
        {
            InitializeComponent();
        }

        private StringBuilder m_logStringBuilder;

        private IList<SMSGraphics.Tile> m_tiles;
        private IList<Color> m_palette;
        private IList<MetaTile> m_metaTiles;
        private TrackLayout m_track;

        // Per-track-type data
        private Dictionary<int, TrackTypeData> m_trackTypeData = new Dictionary<int, TrackTypeData>();

        // The tracks themselved
        private List<Track> m_tracks = new List<Track>();

/*
        private void log(string text, params object[] args)
        {
            m_logStringBuilder.AppendFormat(text, args);
        }

        private void log(IEnumerable<byte> buffer, int limit = 0)
        {
            StringBuilder sb = new StringBuilder();
            foreach (byte b in buffer)
            {
                sb.AppendFormat("{0:X2} ", b);
            }
            log(sb.ToString().PadRight(limit));
        }
*/
        private void btnDecode_Click(object sender, EventArgs e)
        {
            byte[] file = File.ReadAllBytes(tbFilename.Text);
            int offset = Convert.ToInt32(tbOffset.Text, 16);
            BufferHelper bufferHelper = new BufferHelper(file, offset);
            m_logStringBuilder = new StringBuilder();
            IList<byte> decoded = new List<byte>();
            try
            {
                decoded = Codec.Decompress(bufferHelper);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
            tbOutput.Text = HexToString(decoded);
            tbLog.Text = m_logStringBuilder.ToString();
            toolStripStatusLabel1.Text = string.Format(
                "Decoded {0} bytes from {1:X} to {2:X} to {3} bytes of data ({4:P2} compression)",
                bufferHelper.Offset - offset,
                offset,
                bufferHelper.Offset - 1,
                decoded.Count,
                compressionRatio(bufferHelper.Offset - offset, decoded.Count)
                );
        }

        private void btnSearch_Click(object sender, EventArgs e)
        {
            byte[] file = File.ReadAllBytes(tbFilename.Text);
            int offset = Convert.ToInt32(tbOffset.Text, 16) + 1;
            BufferHelper bufferHelper = new BufferHelper(file, offset);
            IList<byte> decoded = null;
            for (; offset < file.Length; ++offset)
            {
                m_logStringBuilder = new StringBuilder();
                try
                {
                    bufferHelper.Offset = offset;
                    decoded = Codec.Decompress(bufferHelper);
                    break; // Nasty!
                }
                catch (Exception) {
                    toolStripStatusLabel1.Text = string.Format(
                        "Failed to find data at {0:X}",
                        offset);
                    Application.DoEvents();
                } // Failure is OK
                bufferHelper = new BufferHelper(file, offset);
            }
            if (decoded == null)
            {
                return;
            }
            tbOffset.Text = Convert.ToString(offset, 16);
            tbOutput.Text = HexToString(decoded);
            tbLog.Text = m_logStringBuilder.ToString();
            toolStripStatusLabel1.Text = string.Format(
                "Decoded {0} bytes from {1:X} to {2:X} to {3} bytes of data ({4:P2} compression)",
                bufferHelper.Offset - offset,
                offset,
                bufferHelper.Offset - 1,
                decoded.Count,
                compressionRatio(bufferHelper.Offset - offset, decoded.Count)
                );
        }

        private double compressionRatio(int compressed, int uncompressed)
        {
            return (double)(uncompressed - compressed) / uncompressed;
        }

        private string HexToString(IEnumerable<byte> data)
        {
            StringBuilder sb = new StringBuilder();
            int i = 0;
            foreach (byte b in data)
            {
                sb.Append(b.ToString("X2")).Append(' ');
                if (++i == 16)
                {
                    sb.AppendLine();
                    i = 0;
                }
            }
            return sb.ToString();
        }

        private void TrackParametersChanged(object sender, EventArgs e)
        {
            try
            {
                LoadLevel();
                RenderPalette();
                RenderTiles();
                RenderMetaTiles();
                RenderTrack();
            }
            catch (Exception)
            {
            }
        }

        private void RenderTrack()
        {
            //pbTrack.Image = m_track.render(m_metaTiles);
        }

        private void RenderMetaTiles()
        {
            // There are 64 metatiles, each 96x96px
            // We render them as an 8x8 grid
            Bitmap bm = new Bitmap(8*96, 8*96);
            Graphics g = Graphics.FromImage(bm);
            g.InterpolationMode = System.Drawing.Drawing2D.InterpolationMode.NearestNeighbor;
            g.PixelOffsetMode = System.Drawing.Drawing2D.PixelOffsetMode.HighQuality;

            int x = 0;
            int y = 0;
            foreach (MetaTile tile in m_metaTiles)
            {
                lock (tile.Bitmap)
                {
                    g.DrawImageUnscaled(tile.Bitmap, x, y);
                }
                x += 96;
                if (x >= bm.Width)
                {
                    x = 0;
                    y += 96;
                }
            }

            pbMetaTiles.Image = bm;
        }

        private void RenderTiles()
        {
            Bitmap bm = new Bitmap(128, 128); // Always just right for Micro Machines
            Graphics g = Graphics.FromImage(bm);
            g.InterpolationMode = System.Drawing.Drawing2D.InterpolationMode.NearestNeighbor;
            g.PixelOffsetMode = System.Drawing.Drawing2D.PixelOffsetMode.HighQuality;

            int x = 0;
            int y = 0;
            foreach (SMSGraphics.Tile tile in m_tiles)
            {
                lock (tile.Bitmap)
                {
                    g.DrawImage(tile.Bitmap, x, y, 8, 8);
                }
                x += 8;
                if (x >= bm.Width)
                {
                    x = 0;
                    y += 8;
                }
            }

            pbTiles.Image = bm;
        }

        private void RenderPalette()
        {
            // We render it to a bitmap
            Bitmap bm = new Bitmap(32, 1);
            int x = 0;
            foreach (Color c in m_palette)
            {
                bm.SetPixel(x++, 0, c);
            }
            pbPalette.Image = bm;
        }

        private void LoadLevel()
        {
            int trackType = cbLevelType.SelectedIndex;
            int trackNumber = Convert.ToInt32(nudStageIndex.Value);

            // Read the file
            byte[] file = File.ReadAllBytes(tbFilename.Text);

            // Load the data for this level
            // Most of the tables are at the start of a page given by a table at 0x3e3a
            byte trackTypeDataPageNumber = file[0x3e3a + trackType];
            int tableOffset = trackTypeDataPageNumber * 16 * 1024;
            int offset2 = Codec.AbsoluteOffset(trackTypeDataPageNumber, BitConverter.ToUInt16(file, tableOffset + 0));
            int offset3 = Codec.AbsoluteOffset(trackTypeDataPageNumber, BitConverter.ToUInt16(file, tableOffset + 2));
            int offsetTrack = Codec.AbsoluteOffset(trackTypeDataPageNumber, BitConverter.ToUInt16(file, tableOffset + 4 + trackNumber * 2));

            // But there's tile data (and other stuff) at 0x3dc8
            byte trackTypeTileDataPageNumber = file[0x3dc8 + trackType];
            byte[] offset1Buffer = new byte[] { file[0x3ddc + trackType], file[0x3de4 + trackType] };
            int offsetTiles = Codec.AbsoluteOffset(trackTypeTileDataPageNumber, BitConverter.ToUInt16(offset1Buffer, 0));

            // And the palette table at 0x17ec2. Palettes are in page 5.
            ushort offsetPalette = BitConverter.ToUInt16(file, 0x17ec2 + trackType * 2);
            int absoluteOffsetPalette = Codec.AbsoluteOffset(5, offsetPalette);

            // First load the palette
            m_palette = SMSGraphics.ReadPalette(file, absoluteOffsetPalette, 32);

            // Then the tiles
            m_tiles = Codec.LoadTiles(file, offsetTiles, m_palette);

            // Metatiles next
            m_metaTiles = Codec.LoadMetaTiles(file, trackType, m_tiles); 

            // Then the track
            m_track = LoadTrack(file, offsetTrack);

            // And the track attributes
            // These are defined in the track order table so I need to feed off that? Maybe
            // build my combo from there...

            // Track names
            int trackNamesOffset = Codec.AbsoluteOffset(3, BitConverter.ToUInt16(file, 0xaace + 0));
            List<string> trackNames = new List<string>();
            // Qualifying race?
            for (int i = 0; i < 29; ++i)
            {
                string trackName = Codec.DecodeString(file, trackNamesOffset + i * 20, 20);
                trackNames.Add(trackName);
            }
        }

        private TrackLayout LoadTrack(IList<byte> file, int offset)
        {
            // We decompress it...
            List<byte> data = Codec.Decompress(file, offset);

            // The first half is metatile indices
            // The second half is position indices
            int halfCount = data.Count / 2;
            TrackLayout track = new TrackLayout(data.GetRange(0, halfCount), data.GetRange(halfCount, halfCount));
            return track;
        }

        private void pbPalette_Paint(object sender, PaintEventArgs e)
        {
            // Picture boxes are funny about drawing 1px tall images...
            e.Graphics.InterpolationMode = System.Drawing.Drawing2D.InterpolationMode.NearestNeighbor;
            e.Graphics.PixelOffsetMode = System.Drawing.Drawing2D.PixelOffsetMode.HighQuality;
            if (pbPalette.Image != null)
            {
                e.Graphics.DrawImage(pbPalette.Image, 0, 0, pbPalette.Width, pbPalette.Height);
            }
            else
            {
                base.OnPaint(e);
            }
        }

        private void btnText_Click(object sender, EventArgs e)
        {
            byte[] file = File.ReadAllBytes(tbFilename.Text);
            int offset = Convert.ToInt32(tbOffset.Text, 16);
            String text = Codec.DecodeString(file, offset);
            tbOutput.Text = text;
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            LoadTracks();
            PopulateTrackList();
        }

        private void PopulateTrackList()
        {
            lvTracks.BeginUpdate();
            lvTracks.Items.Clear();
            ImageList il = new ImageList() { ImageSize = new Size(64, 64), ColorDepth = ColorDepth.Depth24Bit, };
            lvTracks.LargeImageList = il;
            var UIContext = TaskScheduler.FromCurrentSynchronizationContext();
            foreach (Track track in m_tracks)
            {
                // Prettify the name
                string displayName = track.Name.Trim(); // Remove padding
                displayName = Regex.Replace(track.Name, "  +", " "); // Collapse inner spacing
                displayName = displayName.ToLowerInvariant(); // Lowercase
                displayName = Thread.CurrentThread.CurrentCulture.TextInfo.ToTitleCase(displayName); // Title case
                ListViewItem item = new ListViewItem(displayName);
                item.Tag = track;
                lvTracks.Items.Add(item);

                // Do the bitmap creation on a worker thread, but the UI stuff on this thread
                Task.Factory.StartNew(
                    () => track.GetThumbnail(lvTracks.LargeImageList.ImageSize.Width)
                ).ContinueWith(
                    (t) =>
                    {
                        int index = il.Images.Count;
                        il.Images.Add(t.Result);
                        item.ImageIndex = index;
                        toolStripStatusLabel1.Text = string.Format("Loaded {0}/{1} thumbnails...", index + 1, m_tracks.Count);
                    },
                    UIContext
                );
            }
            lvTracks.EndUpdate();
        }

        private void LoadTracks()
        {
            byte[] file = File.ReadAllBytes(tbFilename.Text);
            m_trackTypeData.Clear();
            m_tracks.Clear();

            // We go through the levels table
            const int trackTableOffset = 0x766a; // Start of table
            const int stride = 29; // Offset between chunks
            for (int i = 0; i < 29; ++i)
            {
                int offset = trackTableOffset + i;
                int trackType = file[offset];

                // Helicopters are bad!
                if (trackType == 8)
                {
                    continue;
                }

                int trackIndex = file[offset += stride];
                int topSpeed = file[offset += stride];
                int acceleration = file[offset += stride];
                int deceleration = file[offset += stride];
                int steeringSpeed = file[offset += stride];

                // Load the track type data when first encountered
                TrackTypeData trackTypeData;
                if (!m_trackTypeData.TryGetValue(trackType, out trackTypeData))
                {
                    trackTypeData = new TrackTypeData(file, trackType);
                    m_trackTypeData.Add(trackType, trackTypeData);
                }

                string name;
                switch (i)
                {
                    case 0: // Qualifying race
                        name = Codec.DecodeString(file, 0xbab7, 20);
                        break;
                    case 25: // Final race
                        name = Codec.DecodeString(file, 0xffa1, 30);
                        break;
                    default:
                        name = Codec.DecodeString(file, Codec.AbsoluteOffset(3, BitConverter.ToUInt16(file, 0xaace + (i - 1) * 2)), 20);
                        break;
                }

                // We decompress it...
                byte trackTypeDataPageNumber = file[0x3e3a + trackType];
                int tableOffset = Codec.AbsoluteOffset(trackTypeDataPageNumber, 0x8000);
                int layoutOffset = Codec.AbsoluteOffset(trackTypeDataPageNumber, BitConverter.ToUInt16(file, tableOffset + 4 + trackIndex * 2));
                List<byte> layoutData = Codec.Decompress(file, layoutOffset);

                // The first half is metatile indices
                // The second half is position indices
                int halfCount = layoutData.Count / 2;
                TrackLayout layout = new TrackLayout(layoutData.GetRange(0, halfCount), layoutData.GetRange(halfCount, halfCount));

                Track track = new Track(name, layout, trackTypeData);
                track.Acceleration = acceleration;
                track.Deceleration = deceleration;
                track.TopSpeed = topSpeed;
                track.SteeringSpeed = steeringSpeed;
                track.VehicleType = (Track.VehicleTypeEnum)trackType;
                track.TrackIndex = trackIndex;

                m_tracks.Add(track);
            }
        }

        private void lvTracks_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (lvTracks.SelectedItems.Count == 0)
            {
                pgTrack.SelectedObject = null;
                return;
            }
            pgTrack.SelectedObject = lvTracks.SelectedItems[0].Tag;
        }

        private void editTrackToolStripMenuItem_Click(object sender, EventArgs e)
        {
            if (lvTracks.SelectedItems.Count != 1)
            {
                return;
            }

            // Show it in the track tab
            Track track = lvTracks.SelectedItems[0].Tag as Track;
            trackEditor.Track = track;
            tabControl1.SelectedTab = tabTrack;
        }
    }
}
