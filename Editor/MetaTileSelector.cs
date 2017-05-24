using System;
using System.Collections.Generic;
using System.Drawing;
using System.Windows.Forms;
using System.Drawing.Drawing2D;

namespace MicroMachinesEditor
{
    public sealed partial class MetaTileSelector : ScrollableControl
    {
        #region events

        public event EventHandler<int> OnHover;

        #endregion


        #region constants

        private const int TileSizeInPixels = 96;

        #endregion

        #region Fields

        // The actual data
        private IList<MetaTile> _metaTiles;

        // State
        private int _columnCount;
        private int _rowCount;
        private int _hoveredIndex = -1;
        private int _selectedIndex = -1;

        // Drawing objects
        private readonly Pen _selectionPen = new Pen(SystemColors.Highlight, 2) { Alignment = PenAlignment.Inset };
        private readonly Brush _selectionBrush = new SolidBrush(Color.FromArgb(128, SystemColors.Highlight));
        private readonly Pen _hoverPen = new Pen(SystemColors.HotTrack, 2) { Alignment = PenAlignment.Inset };

        #endregion

        public MetaTileSelector()
        {
            SelectedMetaTileIndex = 0;
            DoubleBuffered = true;
            ResizeRedraw = true;
            InitializeComponent();
        }

        #region Properties

        public IList<MetaTile> MetaTiles {
            get
            {
                return _metaTiles;
            }
            set
            {
                _metaTiles = value;
                // Trigger a reevaluation of the layout
                OnSizeChanged(null);
            }
        }

        public int SelectedMetaTileIndex 
        { 
            get
            {
                return _selectedIndex;
            }
            set
            {
                if (value < 0 || _metaTiles == null || value > _metaTiles.Count || value == _selectedIndex)
                {
                    return;
                }
                // See if we should scroll it into view
                Rectangle newRect = ScreenRectFromIndex(value); // in display coordinates
                if (newRect.Top < 0)
                {
                    // Note that when you read AutoScrollPosition, you get negative numbers
                    // when scrolled; but when setting it, you have to use positive numbers.
                    // Note also that we don't bother checking the X - we should never have 
                    // horizontal scrolling.
                    AutoScrollPosition = new Point(-AutoScrollPosition.X, newRect.Top - AutoScrollPosition.Y);
                }
                else if (newRect.Bottom > Height)
                {
                    AutoScrollPosition = new Point(-AutoScrollPosition.X, newRect.Bottom - Height - AutoScrollPosition.Y);
                }
                // Invalidate rects
                Invalidate(ScreenRectFromIndex(_selectedIndex));
                Invalidate(newRect);
                _selectedIndex = value;
            } 
        }

        #endregion

        #region UI event handlers

        protected override void OnSizeChanged(EventArgs e)
        {
            base.OnSizeChanged(e);
            if (_metaTiles == null)
            {
                return;
            }
            // Set the row/column count
            _columnCount = Math.Max(1, (Width - SystemInformation.VerticalScrollBarWidth) / TileSizeInPixels);
            _rowCount = (int)Math.Ceiling((double)_metaTiles.Count / _columnCount);
            AutoScrollMinSize = new Size(_columnCount * TileSizeInPixels, _rowCount * TileSizeInPixels);
        }

        protected override void OnMouseMove(MouseEventArgs e)
        {
            base.OnMouseMove(e);
            SetHoveredIndex(IndexFromScreenPoint(e.Location));
        }

        protected override void OnMouseLeave(EventArgs e)
        {
            base.OnMouseLeave(e);
            SetHoveredIndex(-1);
        }

        protected override void OnMouseClick(MouseEventArgs e)
        {
            SelectedMetaTileIndex = IndexFromScreenPoint(e.Location);
        }

        protected override void OnPaint(PaintEventArgs e)
        {
            // Clear the area first
            e.Graphics.FillRectangle(SystemBrushes.Window, e.ClipRectangle);
            if (_metaTiles == null)
            {
                e.Graphics.DrawString("No metatiles", SystemFonts.DefaultFont, SystemBrushes.WindowText, 0, 0);
                return;
            }
            // Draw all tiles overlapping the rect
            for (int index = 0; index < _metaTiles.Count; ++index)
            {
                // Is this tile in the clip rectangle?
                Rectangle tileRect = ScreenRectFromIndex(index);
                if (!tileRect.IntersectsWith(e.ClipRectangle))
                {
                    continue;
                }
                MetaTile tile = _metaTiles[index];
                lock (tile.Bitmap)
                {
                    e.Graphics.DrawImageUnscaled(tile.Bitmap, tileRect.Location);
                }
                // Is it selected?
                if (index == SelectedMetaTileIndex)
                {
                    e.Graphics.FillRectangle(_selectionBrush, tileRect);
                    e.Graphics.DrawRectangle(_selectionPen, tileRect);
                }
                    // Is it hovered?
                else if (index == _hoveredIndex)
                {
                    e.Graphics.DrawRectangle(_hoverPen, tileRect);
                }
            }
        }

        #endregion

        #region Private methods

        private void SetHoveredIndex(int index)
        {
            if (index == _hoveredIndex)
            {
                return;
            }
            Invalidate(ScreenRectFromIndex(_hoveredIndex));
            _hoveredIndex = index;
            Invalidate(ScreenRectFromIndex(_hoveredIndex));

            OnHover?.Invoke(this, index);
        }

        // Returns the bounding rect for the given metatile, in screen coordinates.
        private Rectangle ScreenRectFromIndex(int index)
        {
            if (_metaTiles == null || index < 0 || index >= _metaTiles.Count)
            {
                return new Rectangle();
            }
            int x = index % _columnCount;
            int y = index / _columnCount;
            return new Rectangle(x * TileSizeInPixels + AutoScrollPosition.X, y * TileSizeInPixels + AutoScrollPosition.Y, TileSizeInPixels, TileSizeInPixels);
        }

        // Returns the metatile index for the given screen point, or -1 if there isn't one
        private int IndexFromScreenPoint(Point point)
        {
            if (_metaTiles == null)
            {
                return -1;
            }
            var x = (point.X - AutoScrollPosition.X) / TileSizeInPixels;
            var y = (point.Y - AutoScrollPosition.Y) / TileSizeInPixels;
            if (x < 0 || y < 0 || x >= _columnCount || y >= _rowCount)
            {
                return -1;
            }
            var index = y * _columnCount + x;
            if (index >= _metaTiles.Count)
            {
                return -1;
            }
            return index;
        }

        #endregion
    }
}
