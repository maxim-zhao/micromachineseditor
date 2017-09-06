using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Globalization;
using System.Windows.Forms;

namespace MicroMachinesEditor
{
    public sealed partial class TrackRenderer : UserControl
    {
        private Track _track;
        private bool _showGrid;
        private bool _showPositions;
        private bool _showMetaTileFlags;
        private readonly Pen _gridPen = new Pen(Color.Gray);
        private readonly Brush _nonTrackBrush = new SolidBrush(Color.FromArgb(127, Color.Black));
        private readonly Font _positionNumberFont = new Font(SystemFonts.DefaultFont.FontFamily, 30);
        private readonly StringFormat _positionNumberStringFormat = new StringFormat { LineAlignment = StringAlignment.Center, Alignment = StringAlignment.Center };
        private readonly Pen _hoverPen = new Pen(SystemColors.HotTrack, 2) { Alignment = PenAlignment.Inset };
        private Point _hoveredTile;

        public TrackRenderer()
        {
            InitializeComponent();
            MinimumSize = MaximumSize = new Size(32 * 96, 32 * 96);
            DoubleBuffered = true;
        }

        public Track Track
        {
            set
            {
                _track = value;
                Invalidate();
            }
        }

        private void TrackEditor_Paint(object sender, PaintEventArgs e)
        {
            if (_track == null)
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
                    Point p = new Point(x, y);
                    int index = _track.Layout.TileIndexAt(p);
                    Rectangle tileRect = RectForTile(p);
                    if (index < 0 || index >= _track.MetaTiles.Count)
                    {
                        // Error
                        e.Graphics.FillRectangle(Brushes.Red, tileRect);
                        e.Graphics.DrawString($"Invalid metatile index {index}", SystemFonts.DefaultFont, Brushes.White, new RectangleF(0, 0, 96, 96));
                        continue;
                    }
                    MetaTile metaTile = _track.MetaTiles[index];
                    lock (metaTile.Bitmap)
                    {
                        e.Graphics.DrawImageUnscaled(metaTile.Bitmap, tileRect);
                    }

                    if (_showPositions)
                    {
                        int trackPosition = _track.Layout.TrackPositionAt(x, y);
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

                    if (_showGrid)
                    {
                        e.Graphics.DrawRectangle(_gridPen, tileRect);
                    }

                    if (_showMetaTileFlags)
                    {
                        // *
                        // These relate to AI?
                        int flags = _track.Layout.FlagsAt(x, y);
                        // We look up depending on the flags
                        int lookupOffset = 0x1d87;
                        if ((flags & 2) == 0)
                        {
                            lookupOffset = 0x1da7 + metaTile.UnknownDataValue.LookupIndex * 16;
                        }
                        // Then we iterate over the metatile
                        e.Graphics.SmoothingMode = SmoothingMode.HighQuality;
                        for (int yy = 0; yy < 6; ++yy)
                        {
                            for (int xx = 0; xx < 6; ++xx)
                            {
                                // Get the data for this square
                                var behaviourLow = metaTile.behaviourLowAt(xx, yy);
                                // Look up the value
                                int dataOffset = lookupOffset + behaviourLow;
                                int data = _track._file[dataOffset]; // TODO stop accessing this like this
                                // Flip if flag is set
                                if ((flags & 1) == 1)
                                {
                                    data = (data + 16) % 16;
                                }
                                // TODO draw as an arrow
                                var transform = e.Graphics.Transform;
                                // Transform to our arrow position
                                e.Graphics.TranslateTransform(tileRect.X + xx * 16 + 8, tileRect.Y + yy * 16 + 8);
                                e.Graphics.RotateTransform((int)data * 360.0f / 16);
                                // Draw an arrow upwards in the transformed context
                                e.Graphics.DrawLine(Pens.Black, 0, -7, 0, 7);
                                e.Graphics.DrawLine(Pens.Black, 0, -7, 2, -5);
                                e.Graphics.DrawLine(Pens.Black, 0, -7, -2, -5);
                                // Restore the transform
                                e.Graphics.Transform = transform;
                                e.Graphics.DrawString(data.ToString("X1"), SystemFonts.CaptionFont, Brushes.Fuchsia, tileRect.X + xx * 16, tileRect.Y + yy * 16);
                            }
                        }
                        e.Graphics.SmoothingMode = SmoothingMode.Default;
                        // */
                        
                    }

                    if (p == _hoveredTile)
                    {
                        e.Graphics.DrawRectangle(_hoverPen, tileRect);
                    }
                }
            }

        }

        private static Rectangle RectForTile(Point p)
        {
            return new Rectangle(p.X * 96, p.Y * 96, 96, 96);
        }

        public bool ShowGrid
        {
            set
            {
                _showGrid = value;
                Invalidate();
            }
        }

        public bool ShowPositions
        {
            set
            {
                _showPositions = value;
                Invalidate();
            }
        }

        public bool ShowMetaTileFlags
        {
            set
            {
                _showMetaTileFlags = value;
                Invalidate();
            }
        }

        public Point HoveredTile
        {
            set
            {
                if (_hoveredTile == value)
                {
                    return;
                }
                InvalidateTile(_hoveredTile);
                _hoveredTile = value;
                InvalidateTile(value);
            }
        }

        public void InvalidateTile(Point p)
        {
            Invalidate(RectForTile(p));
        }
    }
}
