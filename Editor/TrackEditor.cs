using System;
using System.Drawing;
using System.Windows.Forms;

namespace MicroMachinesEditor
{
    public partial class TrackEditor : UserControl
    {
        private Track _track;
        private Point _hoveredPoint = new Point(-1, -1);

        public TrackEditor()
        {
            InitializeComponent();
        }

        public Track Track
        {
            set
            {
                _track = value;
                if (value == null)
                {
                    trackRenderer.Track = null;
                    metaTileSelector.MetaTiles = null;
                }
                else
                {
                    trackRenderer.Track = _track;
                    metaTileSelector.MetaTiles = _track.MetaTiles;
                }
            }
        }

        private void btnTrackRotateUp_Click(object sender, EventArgs e)
        {
            _track.Layout.Rotate(0, -1);
            trackRenderer.Invalidate();
        }

        private void btnTrackRotateDown_Click(object sender, EventArgs e)
        {
            _track.Layout.Rotate(0, +1);
            trackRenderer.Invalidate();
        }

        private void btnTrackRotateLeft_Click(object sender, EventArgs e)
        {
            _track.Layout.Rotate(-1, 0);
            trackRenderer.Invalidate();
        }

        private void btnTrackRotateRight_Click(object sender, EventArgs e)
        {
            _track.Layout.Rotate(+1, 0);
            trackRenderer.Invalidate();
        }

        private void tbBlank_Click(object sender, EventArgs e)
        {
            if (MessageBox.Show(this,
                "Are you sure? This will erase the entire map!",
                null,
                MessageBoxButtons.YesNo,
                MessageBoxIcon.Question,
                MessageBoxDefaultButton.Button2) == DialogResult.Yes)
            {
                _track.Layout.Blank(metaTileSelector.SelectedMetaTileIndex);
                trackRenderer.Invalidate();
            }
        }

        private void tbGrid_Click(object sender, EventArgs e)
        {
            trackRenderer.ShowGrid = tbGrid.Checked;
        }

        private void trackRenderer_MouseDown(object sender, MouseEventArgs e)
        {
            if (e.Button == MouseButtons.Left)
            {
                if (tbEyeDropper.Checked || ModifierKeys == Keys.Control)
                {
                    EyeDropper(e.Location);
                    tbEyeDropper.Checked = false;
                }
                else
                {
                    SetMetaTile(PointFromLocation(e.Location));
                }
            }
        }

        private void EyeDropper(Point location)
        {
            if (_track == null)
            {
                return;
            }
            // Convert to tile coordinates
            Point p = PointFromLocation(location);
            int indexUnderMouse = _track.Layout.TileIndexAt(p);
            metaTileSelector.SelectedMetaTileIndex = indexUnderMouse;
        }

        private void trackRenderer_MouseMove(object sender, MouseEventArgs e)
        {
            if (_track == null)
            {
                return;
            }
            Point p = PointFromLocation(e.Location);
            if (e.Button == MouseButtons.Left)
            {
                SetMetaTile(p);
            }
            SetHoveredMetatile(p);
            mouseLocation.Text = $"{p.X}, {p.Y} @ ${p.X + p.Y * 32:X} = ${_track.Layout.TileIndexAt(_hoveredPoint):X}";
        }

        private void SetHoveredMetatile(Point p)
        {
            if (p == _hoveredPoint)
            {
                return;
            }
            trackRenderer.HoveredTile = p;
            _hoveredPoint = p;
        }

        private static Point PointFromLocation(Point p)
        {
            return new Point(p.X / 96, p.Y / 96);
        }

        private void SetMetaTile(Point p)
        {
            if (_track == null)
            {
                return;
            }
            int metaTileIndex = metaTileSelector.SelectedMetaTileIndex;
            if (metaTileIndex < 0)
            {
                return;
            }
            int existingIndex = _track.Layout.TileIndexAt(p);
            if (existingIndex == metaTileIndex)
            {
                return;
            }
            _track.Layout.SetTileIndex(p, (byte)metaTileIndex);
            trackRenderer.InvalidateTile(p);
        }

        private void tbTogglePositions_Click(object sender, EventArgs e)
        {
            trackRenderer.ShowPositions = tbTogglePositions.Checked;
        }

        private void tbMetatileFlags_Click(object sender, EventArgs e)
        {
            trackRenderer.ShowMetaTileFlags = tbMetatileFlags.Checked;
        }

        private void metaTileSelector_OnHover(object sender, int index)
        {
            mouseLocation.Text = $"Metatile {index} = ${index:X2}";
        }
    }
}
