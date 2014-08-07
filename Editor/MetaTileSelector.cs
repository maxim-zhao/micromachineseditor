using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Drawing.Drawing2D;

namespace MicroMachinesEditor
{
    public partial class MetaTileSelector : UserControl
    {
        private IList<MetaTile> metaTiles;
        private int selectedIndex;
        private Pen selectionPen = new Pen(SystemColors.Highlight, 2) { Alignment = PenAlignment.Inset, };
        private Brush selectionBrush = new SolidBrush(Color.FromArgb(128, SystemColors.Highlight));

        public MetaTileSelector()
        {
            SelectedMetaTileIndex = 0;
            DoubleBuffered = true;
            InitializeComponent();
        }

        public IList<MetaTile> MetaTiles {
            get
            {
                return this.metaTiles;
            }
            set
            {
                this.metaTiles = value;
                this.Invalidate();
            }
        }

        public int SelectedMetaTileIndex 
        { 
            get
            {
                return this.selectedIndex;
            }
            set
            {
                if (value < 0 || this.metaTiles == null || value > this.metaTiles.Count)
                {
                    return;
                }
                // Invalidate rects
                Invalidate(RectFromIndex(this.selectedIndex));
                Invalidate(RectFromIndex(value));
                this.selectedIndex = value;
            } 
        }

        // Makes autosizing work, so long as the control is docked :)
        public override Size GetPreferredSize(Size proposedSize)
        {
            if (this.metaTiles == null)
            {
                return new Size(96, 96);
            }
            int w = proposedSize.Width / 96;
            int h = (int)Math.Ceiling((double)this.metaTiles.Count / w);
            return new Size(w * 96, h * 96);        
        }

        protected override void OnPaint(PaintEventArgs e)
        {
            e.Graphics.FillRectangle(SystemBrushes.Window, e.ClipRectangle);
            if (this.metaTiles == null)
            {
                e.Graphics.DrawString("No metatiles", SystemFonts.DefaultFont, SystemBrushes.WindowText, 0, 0);
                return;
            }
            // Get the width of the control
            for (int index = 0; index < this.metaTiles.Count; ++index)
            {
                // Is this tile in the clip rectangle?
                Rectangle tileRect = RectFromIndex(index);
                if (tileRect.IntersectsWith(e.ClipRectangle))
                {
                    MetaTile tile = this.metaTiles[index];
                    lock (tile.Bitmap)
                    {
                        e.Graphics.DrawImageUnscaled(tile.Bitmap, tileRect.Location);
                    }
                    // Is it selected?
                    if (index == SelectedMetaTileIndex)
                    {
                        e.Graphics.FillRectangle(selectionBrush, tileRect);
                        e.Graphics.DrawRectangle(selectionPen, tileRect);
                    }
                }
            }
        }

        private Rectangle RectFromIndex(int index)
        {
            if (this.metaTiles == null)
            {
                return new Rectangle();
            }
            int maxX = this.Width / 96;
            int x = index % maxX;
            int y = index / maxX;
            return new Rectangle(x * 96, y * 96, 96, 96);
        }

        protected override void OnMouseClick(MouseEventArgs e)
        {
            int index = TileFromPoint(e.Location);
            if (index > -1)
            {
                this.SelectedMetaTileIndex = index;
            }
// 	        base.OnMouseClick(e);
        }

        private int TileFromPoint(Point point)
        {
            if (this.metaTiles == null)
            {
                return -1;
            }
            int columnCount = this.Width / 96;
            int rowCount = (int)Math.Ceiling((double)this.metaTiles.Count / columnCount);
            int x = (point.X / 96);
            int y = (point.Y / 96);
            if (x < 0 || y < 0 || x >= columnCount || y >= rowCount)
            {
                return -1;
            }
            int index = y * columnCount + x;
            if (index >= this.metaTiles.Count)
            {
                index = -1;
            }
            return index;
        }
    }
}
