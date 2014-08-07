using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace MicroMachinesEditor
{
    public partial class TrackRenderer : UserControl
    {
        private TrackLayout trackLayout;
        private IList<MetaTile> metaTiles;
        private bool showGrid;
        private Pen gridPen = new Pen(Color.Gray);
        private Brush nonTrackBrush = new SolidBrush(Color.FromArgb(127, Color.Black));
        private Font positionNumberFont = new Font(SystemFonts.DefaultFont.FontFamily, 36);
        private StringFormat positionNumberStringFormat = new StringFormat() { LineAlignment = StringAlignment.Center, Alignment = StringAlignment.Center, };
        private bool showPositions;
        private bool showMetaTileFlags;

        public TrackRenderer()
        {
            InitializeComponent();
            this.MinimumSize = this.MaximumSize = new Size(32 * 96, 32 * 96);
            this.DoubleBuffered = true;
        }

        public TrackLayout TrackLayout
        {
            get
            {
                return trackLayout;
            }
            set
            {
                this.trackLayout = value;
                Invalidate();
            }
        }

        public IList<MetaTile> MetaTiles
        {
            get
            {
                return this.metaTiles;
            }
            set
            {
                this.metaTiles = value;
                Invalidate();
            }
        }

        private void TrackEditor_Paint(object sender, PaintEventArgs e)
        {
            if (this.trackLayout == null || this.metaTiles == null)
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
                    int index = this.trackLayout.TileIndexAt(x, y);
                    Rectangle tileRect = new Rectangle(x * 96, y * 96, 96, 96);
                    if (index < 0 || index >= this.metaTiles.Count)
                    {
                        // Error
                        e.Graphics.FillRectangle(Brushes.Red, tileRect);
                        e.Graphics.DrawString(string.Format("Invalid metatile index {0}", index), SystemFonts.DefaultFont, Brushes.White, 0, 0);
                    }
                    MetaTile tile = this.metaTiles[index];
                    lock (tile.Bitmap)
                    {
                        e.Graphics.DrawImageUnscaled(tile.Bitmap, tileRect);
                    }

                    if (this.showPositions)
                    {
                        int trackPosition = this.trackLayout.TrackPositionAt(x, y);
                        if (trackPosition == 0)
                        {
                            e.Graphics.FillRectangle(nonTrackBrush, tileRect);
                        }
                        else
                        {
                            e.Graphics.DrawString(trackPosition.ToString(), this.positionNumberFont, Brushes.Black, tileRect, this.positionNumberStringFormat);
                            tileRect.Offset(-1, -1);
                            e.Graphics.DrawString(trackPosition.ToString(), this.positionNumberFont, Brushes.White, tileRect, this.positionNumberStringFormat);
                        }
                    }

                    if (this.showGrid)
                    {
                        e.Graphics.DrawRectangle(this.gridPen, tileRect);
                    }

                    if (this.ShowMetaTileFlags)
                    {
                        int flags = this.trackLayout.FlagsAt(x, y);
                        if (flags != 0)
                        {
                            e.Graphics.DrawString(flags.ToString(), SystemFonts.CaptionFont, Brushes.Fuchsia, tileRect);
                        }
                    }
                }
            }

        }

        public bool ShowGrid
        {
            get
            {
                return this.showGrid;
            }
            set
            {
                this.showGrid = value;
                this.Invalidate();
            }
        }

        public bool ShowPositions
        {
            get
            {
                return this.showPositions;
            }
            set
            {
                this.showPositions = value;
                this.Invalidate();
            }
        }

        public bool ShowMetaTileFlags
        {
            get
            {
                return this.showMetaTileFlags;
            }
            set
            {
                this.showMetaTileFlags = value;
                this.Invalidate();
            }
        }
    }
}
