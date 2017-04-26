using System.Collections.Generic;
using System.Drawing;
using System.Globalization;
using System.Windows.Forms;

namespace MicroMachinesEditor
{
    public sealed partial class TrackRenderer : UserControl
    {
        private TrackLayout _trackLayout;
        private IList<MetaTile> _metaTiles;
        private bool _showGrid;
        private bool _showPositions;
        private bool _showMetaTileFlags;
        private readonly Pen _gridPen = new Pen(Color.Gray);
        private readonly Brush _nonTrackBrush = new SolidBrush(Color.FromArgb(127, Color.Black));
        private readonly Font _positionNumberFont = new Font(SystemFonts.DefaultFont.FontFamily, 30);
        private readonly StringFormat _positionNumberStringFormat = new StringFormat { LineAlignment = StringAlignment.Center, Alignment = StringAlignment.Center };

        public TrackRenderer()
        {
            InitializeComponent();
            MinimumSize = MaximumSize = new Size(32 * 96, 32 * 96);
            DoubleBuffered = true;
        }

        public TrackLayout TrackLayout
        {
            get
            {
                return _trackLayout;
            }
            set
            {
                _trackLayout = value;
                Invalidate();
            }
        }

        public IList<MetaTile> MetaTiles
        {
            get
            {
                return _metaTiles;
            }
            set
            {
                _metaTiles = value;
                Invalidate();
            }
        }

        private void TrackEditor_Paint(object sender, PaintEventArgs e)
        {
            if (_trackLayout == null || _metaTiles == null)
            {
                e.Graphics.FillRectangle(SystemBrushes.Window, e.ClipRectangle);
                e.Graphics.DrawString("No track data", SystemFonts.DefaultFont, SystemBrushes.WindowText, 0, 0);
                return;
            }

            // Calculate the tile index ranges
            int minX = e.ClipRectangle.Left / 96;
            int maxX = (e.ClipRectangle.Right - 1) / 96;
            int minY = e.ClipRectangle.Top / 96;
            int maxY = (e.ClipRectangle.Bottom - 1) / 96;
            for (int y = minY; y <= maxY; ++y)
            {
                for (int x = minX; x <= maxX; ++x)
                {
                    int index = _trackLayout.TileIndexAt(x, y);
                    var tileRect = new Rectangle(x * 96, y * 96, 96, 96);
                    if (index < 0 || index >= _metaTiles.Count)
                    {
                        // Error
                        e.Graphics.FillRectangle(Brushes.Red, tileRect);
                        e.Graphics.DrawString($"Invalid metatile index {index}", SystemFonts.DefaultFont, Brushes.White, 0, 0);
                    }
                    MetaTile tile = _metaTiles[index];
                    lock (tile.Bitmap)
                    {
                        e.Graphics.DrawImageUnscaled(tile.Bitmap, tileRect);
                    }

                    if (ShowPositions)
                    {
                        int trackPosition = _trackLayout.TrackPositionAt(x, y);
                        if (trackPosition == 0)
                        {
                            e.Graphics.FillRectangle(_nonTrackBrush, tileRect);
                        }
                        else
                        {
                            e.Graphics.DrawString(trackPosition.ToString(CultureInfo.InvariantCulture), _positionNumberFont, Brushes.Black, tileRect, _positionNumberStringFormat);
                            tileRect.Offset(-1, -1);
                            e.Graphics.DrawString(trackPosition.ToString(CultureInfo.InvariantCulture), _positionNumberFont, Brushes.White, tileRect, _positionNumberStringFormat);
                        }
                    }

                    if (ShowGrid)
                    {
                        e.Graphics.DrawRectangle(_gridPen, tileRect);
                    }

                    if (ShowMetaTileFlags)
                    {
                        int flags = _trackLayout.FlagsAt(x, y);
                        if (flags != 0)
                        {
                            e.Graphics.DrawString(flags.ToString(CultureInfo.InvariantCulture), SystemFonts.CaptionFont, Brushes.Fuchsia, tileRect);
                        }
                    }
                }
            }

        }

        public bool ShowGrid
        {
            get
            {
                return _showGrid;
            }
            set
            {
                _showGrid = value;
                Invalidate();
            }
        }

        public bool ShowPositions
        {
            get
            {
                return _showPositions;
            }
            set
            {
                _showPositions = value;
                Invalidate();
            }
        }

        public bool ShowMetaTileFlags
        {
            get
            {
                return _showMetaTileFlags;
            }
            set
            {
                _showMetaTileFlags = value;
                Invalidate();
            }
        }
    }
}
