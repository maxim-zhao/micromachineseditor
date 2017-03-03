using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Drawing2D;
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

        private IList<SMSGraphics.Tile> _tiles;
        private IList<Color> _palette;
        private IList<MetaTile> _metaTiles;
        private byte[] _raw;

        // Per-track-type data
        private readonly Dictionary<int, TrackTypeData> _trackTypeData = new Dictionary<int, TrackTypeData>();

        // The tracks themselved
        private readonly List<Track> _tracks = new List<Track>();
        private TrackLayout _track;

        // We use this to invoke things on the UI thread
        private TaskScheduler _uiContext;

        /*
                private void log(string text, params object[] args)
                {
                    _logStringBuilder.AppendFormat(text, args);
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
        
        #region Raw tab

        private void btnDecode_Click(object sender, EventArgs e)
        {
            byte[] file = File.ReadAllBytes(tbFilename.Text);
            int offset = Convert.ToInt32(tbOffset.Text, 16);
            var bufferHelper = new BufferHelper(file, offset);
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
            Log($"Decoded {bufferHelper.Offset - offset} bytes from {offset:X} to {bufferHelper.Offset - 1:X} to {decoded.Count} bytes of data ({CompressionRatio(bufferHelper.Offset - offset, decoded.Count):P2} compression)");

            _raw = decoded.ToArray();
            RenderRawAsTiles();
        }

        private void btnSearch_Click(object sender, EventArgs e)
        {
            byte[] file = File.ReadAllBytes(tbFilename.Text);
            int offset = Convert.ToInt32(tbOffset.Text, 16) + 1;
            var bufferHelper = new BufferHelper(file, offset);
            IList<byte> decoded = null;
            for (; offset < file.Length; ++offset)
            {
                try
                {
                    bufferHelper.Offset = offset;
                    decoded = Codec.Decompress(bufferHelper);
                    if (decoded.Count > 16)
                    {
                        break; // Nasty!
                    }
                }
                catch (Exception) {
                    Log($"Failed to find data at {offset:X}");
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
            Log($"Decoded {bufferHelper.Offset - offset} bytes from {offset:X} to {bufferHelper.Offset - 1:X} to {decoded.Count} bytes of data ({CompressionRatio(bufferHelper.Offset - offset, decoded.Count):P2} compression)");
        }

        private void btnText_Click(object sender, EventArgs e)
        {
            tbOutput.Text = Codec.DecodeString(File.ReadAllBytes(tbFilename.Text), Convert.ToInt32(tbOffset.Text, 16));
        }

        private static double CompressionRatio(int compressed, int uncompressed)
        {
            return (double)(uncompressed - compressed) / uncompressed;
        }

        private static string HexToString(IEnumerable<byte> data)
        {
            var sb = new StringBuilder();
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

        #endregion

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
            //pbTrack.Image = _track.render(_metaTiles);
        }

        private void RenderMetaTiles()
        {
            // There are 64 metatiles, each 96x96px
            // We render them as an 8x8 grid
            var bm = new Bitmap(8*96/8, 8*8*96);
            var g = Graphics.FromImage(bm);
            g.InterpolationMode = InterpolationMode.NearestNeighbor;
            g.PixelOffsetMode = PixelOffsetMode.HighQuality;

            int x = 0;
            int y = 0;
            foreach (var metaTile in _metaTiles)
            {
                lock (metaTile.Bitmap)
                {
                    g.DrawImageUnscaled(metaTile.Bitmap, x, y);
                }
                x += 96;
                if (x >= bm.Width)
                {
                    x = 0;
                    y += 96;
                }
            }

            pbMetaTiles.Image = bm;
            Clipboard.SetImage(bm);
        }

        private void RenderTiles()
        {
            var bm = new Bitmap(128, 128); // Always just right for Micro Machines
            Graphics g = Graphics.FromImage(bm);
            g.InterpolationMode = InterpolationMode.NearestNeighbor;
            g.PixelOffsetMode = PixelOffsetMode.HighQuality;

            // Set to transparent
            g.Clear(Color.Transparent);

            int x = 0;
            int y = 0;
            foreach (var tile in _tiles)
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
            var bm = new Bitmap(32, 1);
            int x = 0;
            foreach (Color c in _palette)
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
            int behaviourDataOffset = Codec.AbsoluteOffset(trackTypeDataPageNumber, BitConverter.ToUInt16(file, tableOffset + 0));
            int wallDataOffset = Codec.AbsoluteOffset(trackTypeDataPageNumber, BitConverter.ToUInt16(file, tableOffset + 2));
            int offsetTrack = Codec.AbsoluteOffset(trackTypeDataPageNumber, BitConverter.ToUInt16(file, tableOffset + 4 + trackNumber * 2));

            // But there's tile data (and other stuff) at 0x3dc8
            byte trackTypeTileDataPageNumber = file[0x3dc8 + trackType];
            byte[] offset1Buffer = { file[0x3ddc + trackType], file[0x3de4 + trackType] };
            int offsetTiles = Codec.AbsoluteOffset(trackTypeTileDataPageNumber, BitConverter.ToUInt16(offset1Buffer, 0));

            // And the palette table at 0x17ec2. Palettes are in page 5.
            ushort offsetPalette = BitConverter.ToUInt16(file, 0x17ec2 + trackType * 2);
            int absoluteOffsetPalette = Codec.AbsoluteOffset(5, offsetPalette);

            // First load the palette
            _palette = SMSGraphics.ReadPalette(file, absoluteOffsetPalette, 32);

            // Then the tiles
            _tiles = Codec.LoadTiles(file, offsetTiles, _palette);

            // Metatiles next
            _metaTiles = Codec.LoadMetaTiles(file, trackType, _tiles); 

            // Then the track
            _track = LoadTrack(file, offsetTrack);

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
            return new TrackLayout(data.GetRange(0, halfCount), data.GetRange(halfCount, halfCount));
        }

        private void pbPalette_Paint(object sender, PaintEventArgs e)
        {
            // Picture boxes are funny about drawing 1px tall images...
            e.Graphics.InterpolationMode = InterpolationMode.NearestNeighbor;
            e.Graphics.PixelOffsetMode = PixelOffsetMode.HighQuality;
            if (pbPalette.Image != null)
            {
                e.Graphics.DrawImage(pbPalette.Image, 0, 0, pbPalette.Width, pbPalette.Height);
            }
            else
            {
                base.OnPaint(e);
            }
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            _uiContext = TaskScheduler.FromCurrentSynchronizationContext();

            LoadTracks();
            PopulateTrackList();
        }

        private void Log(string message)
        {
            // May be called on any thread, so we marshal it back to the UI
            var now = DateTime.Now;
            BeginInvoke(new Action(() =>
            {
                tbLog.AppendText(now.ToString("HH:mm:ss.fff") + " " + message + Environment.NewLine);
                toolStripStatusLabel1.Text = message;
            }));
        }

        private void PopulateTrackList()
        {
            lvTracks.BeginUpdate();
            lvTracks.Items.Clear();
            var il = new ImageList { ImageSize = new Size(128, 128), ColorDepth = ColorDepth.Depth24Bit, };
            lvTracks.LargeImageList = il;
            foreach (var track in _tracks)
            {
                // Prettify the name
                string displayName = track.Name.Trim(); // Remove padding
                displayName = Regex.Replace(displayName, "  +", " "); // Collapse inner spacing
                displayName = displayName.ToLowerInvariant(); // Lowercase
                displayName = Thread.CurrentThread.CurrentCulture.TextInfo.ToTitleCase(displayName); // Title case
                var item = new ListViewItem(displayName) {Tag = track};
                lvTracks.Items.Add(item);

                // Do the bitmap creation on a worker thread, but the UI stuff on this thread
                Track track1 = track;
                Task.Factory.StartNew(
                    () => track1.GetThumbnail(lvTracks.LargeImageList.ImageSize.Width)
                ).ContinueWith(
                    (t) =>
                    {
                        int index = il.Images.Count;
                        il.Images.Add(t.Result);
                        item.ImageIndex = index;
                        Log($"Loaded {index + 1}/{_tracks.Count} thumbnails...");
                    },
                    _uiContext
                );
            }
            lvTracks.EndUpdate();
        }

        private void LoadTracks()
        {
            Log("Reading track data...");
            byte[] file = File.ReadAllBytes(tbFilename.Text);
            _trackTypeData.Clear();
            _tracks.Clear();

            // We go through the levels table
            const int trackTableOffset = 0x766a; // Start of table
            const int stride = 29; // Offset between chunks
            for (int i = 0; i < 29; ++i)
            {
                Log($"Loading track {i}");
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
                if (!_trackTypeData.TryGetValue(trackType, out trackTypeData))
                {
                    Log($"Loading track tyoe data for type {trackType}");
                    trackTypeData = new TrackTypeData(file, trackType);
                    _trackTypeData.Add(trackType, trackTypeData);
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

                Log($"Track name is \"{name}\"");

                // We decompress it...
                byte trackTypeDataPageNumber = file[0x3e3a + trackType];
                int tableOffset = Codec.AbsoluteOffset(trackTypeDataPageNumber, 0x8000);
                int layoutOffset = Codec.AbsoluteOffset(trackTypeDataPageNumber, BitConverter.ToUInt16(file, tableOffset + 4 + trackIndex * 2));
                List<byte> layoutData = Codec.Decompress(file, layoutOffset);

                // The first half is metatile indices
                // The second half is position indices
                int halfCount = layoutData.Count / 2;
                var layout = new TrackLayout(layoutData.GetRange(0, halfCount), layoutData.GetRange(halfCount, halfCount));

                var track = new Track(name, layout, trackTypeData)
                {
                    AccelerationDelay = acceleration,
                    DecelerationDelay = deceleration,
                    TopSpeed = topSpeed,
                    SteeringDelay = steeringSpeed,
                    VehicleType = (Track.VehicleTypes) trackType,
                    TrackIndex = trackIndex
                };

                _tracks.Add(track);
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
            var track = lvTracks.SelectedItems[0].Tag as Track;
            trackEditor.Track = track;
            tabControl1.SelectedTab = tabTrack;
        }

        private void btnDecodeRun_Click(object sender, EventArgs e)
        {
            byte[] file = File.ReadAllBytes(tbFilename.Text);
            int offset = Convert.ToInt32(tbOffset.Text, 16);
            var bufferHelper = new BufferHelper(file, offset);
            IList<byte> decoded = new List<byte>();
            try
            {
                decoded = Codec.DecompressRLE(bufferHelper);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
            tbOutput.Text = HexToString(decoded);
            Log($"Decoded {bufferHelper.Offset - offset} bytes from {offset:X} to {bufferHelper.Offset - 1:X} to {decoded.Count} bytes of data ({CompressionRatio(bufferHelper.Offset - offset, decoded.Count):P2} compression)");
        }

        private void btnDecodeRaw_Click(object sender, EventArgs e)
        {
            byte[] file = File.ReadAllBytes(tbFilename.Text);
            int offset = Convert.ToInt32(tbOffset.Text, 16);
            _raw = file.Skip(offset).Take(file.Length - offset).ToArray();
            RenderRawAsTiles();
        }

        private void RenderRawAsTiles()
        {
            if (_raw == null || _raw.Length == 0)
            {
                return;
            }
            if (cbPalette.SelectedIndex == -1)
            {
                cbPalette.SelectedIndex = 0;
            }
            var paletteOffset = Convert.ToInt32(cbPalette.Text.Split(' ')[0], 16);
            if (cbPalette.Text.Contains("(GG)"))
            {
                _palette = SMSGraphics.ReadPaletteGG(File.ReadAllBytes(tbFilename.Text), paletteOffset, 16);
            }
            else
            {
                _palette = SMSGraphics.ReadPalette(File.ReadAllBytes(tbFilename.Text), paletteOffset, 16);
            }
            if (cbPalette.Text.Contains("sprite"))
            {
                // Hot pink transparency
                _palette[0] = Color.Fuchsia;
            }
            byte[] data = _raw.Skip(Convert.ToInt32(udSkip.Value)).ToArray();
            var bpp = Convert.ToInt32(numericUpDown1.Value);
            int numBytes = Math.Min(bpp * 8 * 512, data.Length);
            int numTiles = numBytes / bpp / 8;
            var tiles = SMSGraphics.ReadTiles(data, 0, numBytes, _palette, bpp);
            var width = Convert.ToInt32(udImageWidth.Value);
            var height = Convert.ToInt32(Math.Ceiling(numTiles * 8.0 / width) * 8);
            var bm = new Bitmap(width, height);
            Graphics g = Graphics.FromImage(bm);
            g.InterpolationMode = InterpolationMode.NearestNeighbor;
            g.PixelOffsetMode = PixelOffsetMode.HighQuality;

            // Set to transparent
            g.Clear(Color.Transparent);

            int x = 0;
            int y = 0;
            foreach (var tile in tiles)
            {
                g.DrawImage(tile.Bitmap, x, y, 8, 8);
                x += 8;
                if (x >= bm.Width)
                {
                    x = 0;
                    y += 8;
                }
            }

            pbRaw.Image = bm;
            Clipboard.SetImage(bm);
        }

        private void numericUpDown1_ValueChanged(object sender, EventArgs e)
        {
            RenderRawAsTiles();
        }

        private void btnDecompressRun_Click(object sender, EventArgs e)
        {
            byte[] file = File.ReadAllBytes(tbFilename.Text);
            int offset = Convert.ToInt32(tbOffset.Text, 16);
            int runBytes = Convert.ToInt32(udRunBytes.Value);
            int rawOffset = offset + runBytes;
            var result = new List<byte>();
            byte lastByte = 0;
            foreach (var b in file.Skip(offset).Take(runBytes))
            {
                for (int i = 0; i < 8; ++i)
                {
                    var bit = (b >> (7 - i)) & 1;
                    if (bit == 0)
                    {
                        lastByte = file[rawOffset++];
                        result.Add(lastByte);
                    }
                    else
                    {
                        result.Add(lastByte);
                    }
                }
            }
            _raw = result.ToArray();
            RenderRawAsTiles();
            Log($"Decoded {rawOffset - offset} bytes from {offset:X} to {rawOffset - 1:X} to {result.Count} bytes of data ({CompressionRatio(rawOffset - offset, result.Count):P2} compression)");
        }
    }
}
