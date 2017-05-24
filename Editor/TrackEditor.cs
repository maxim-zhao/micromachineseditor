using System;
using System.Drawing;
using System.Windows.Forms;

namespace MicroMachinesEditor
{
    public partial class TrackEditor : UserControl
    {
        private Track _track;

        public TrackEditor()
        {
            InitializeComponent();
        }

        public Track Track
        {
            get
            {
                return _track;
            }
            set
            {
                _track = value;
                if (value == null)
                {
                    trackRenderer.TrackLayout = null;
                    trackRenderer.MetaTiles = null;
                    metaTileSelector.MetaTiles = null;
                }
                else
                {
                    trackRenderer.TrackLayout = _track.Layout;
                    trackRenderer.MetaTiles = _track.MetaTiles;
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
                    SetMetaTile(e.Location);
                }
            }
        }

        private void EyeDropper(Point p)
        {
            if (_track == null)
            {
                return;
            }
            // Convert to tile coordinates
            int x = p.X / 96;
            int y = p.Y / 96;
            if (x < 0 || x > 31 || y < 0 || y > 31)
            {
                return;
            }
            int indexUnderMouse = _track.Layout.TileIndexAt(x, y);
            metaTileSelector.SelectedMetaTileIndex = indexUnderMouse;
        }

        private void trackRenderer_MouseMove(object sender, MouseEventArgs e)
        {
            if (_track == null)
            {
                return;
            }
            if (e.Button == MouseButtons.Left)
            {
                SetMetaTile(e.Location);
            }
            // Convert to tile coordinates
            int x = e.Location.X / 96;
            int y = e.Location.Y / 96;
            mouseLocation.Text = $"{x}, {y} @ ${x + y * 32:X} = ${_track.Layout.TileIndexAt(x, y):X}";
        }

        private void SetMetaTile(Point p)
        {
            if (_track == null)
            {
                return;
            }
            // Convert to tile coordinates
            int x = p.X / 96;
            int y = p.Y / 96;
            if (x < 0 || x > 31 || y < 0 || y > 31)
            {
                return;
            }
            int metaTileIndex = metaTileSelector.SelectedMetaTileIndex;
            if (metaTileIndex < 0)
            {
                return;
            }
            int existingIndex = _track.Layout.TileIndexAt(x, y);
            if (existingIndex == metaTileIndex)
            {
                return;
            }
            _track.Layout.SetTileIndex(x, y, (byte)metaTileIndex);
            Rectangle tileRect = new Rectangle(x * 96, y * 96, 96, 96);
            trackRenderer.Invalidate(tileRect);
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
