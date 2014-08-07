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
    public partial class TrackEditor : UserControl
    {
        private Track track;

        public TrackEditor()
        {
            InitializeComponent();
        }

        public Track Track
        {
            get
            {
                return this.track;
            }
            set
            {
                this.track = value;
                if (value == null)
                {
                    this.trackRenderer.TrackLayout = null;
                    this.trackRenderer.MetaTiles = null;
                    this.metaTileSelector.MetaTiles = null;
                }
                else
                {
                    this.trackRenderer.TrackLayout = this.track.Layout;
                    this.trackRenderer.MetaTiles = this.track.MetaTiles;
                    this.metaTileSelector.MetaTiles = this.track.MetaTiles;
                }
            }
        }

        private void btnTrackRotateUp_Click(object sender, EventArgs e)
        {
            this.track.Layout.Rotate(0, -1);
            trackRenderer.Invalidate();
        }

        private void btnTrackRotateDown_Click(object sender, EventArgs e)
        {
            this.track.Layout.Rotate(0, +1);
            trackRenderer.Invalidate();
        }

        private void btnTrackRotateLeft_Click(object sender, EventArgs e)
        {
            this.track.Layout.Rotate(-1, 0);
            trackRenderer.Invalidate();
        }

        private void btnTrackRotateRight_Click(object sender, EventArgs e)
        {
            this.track.Layout.Rotate(+1, 0);
            trackRenderer.Invalidate();
        }

        private void tbBlank_Click(object sender, EventArgs e)
        {
            if (MessageBox.Show(this,
                "Are you sure? This will erase the entire map!",
                null,
                MessageBoxButtons.YesNo,
                MessageBoxIcon.Question,
                MessageBoxDefaultButton.Button2) == System.Windows.Forms.DialogResult.Yes)
            {
                this.track.Layout.Blank(metaTileSelector.SelectedMetaTileIndex);
                trackRenderer.Invalidate();
            }
        }

        private void tbGrid_Click(object sender, EventArgs e)
        {
            trackRenderer.ShowGrid = tbGrid.Checked;
        }

        private void trackRenderer_MouseDown(object sender, MouseEventArgs e)
        {
            if (e.Button == System.Windows.Forms.MouseButtons.Left)
            {
                if (tbEyeDropper.Checked || Control.ModifierKeys == Keys.Control)
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
            if (this.track == null)
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
            int indexUnderMouse = this.track.Layout.TileIndexAt(x, y);
            metaTileSelector.SelectedMetaTileIndex = indexUnderMouse;
        }

        private void trackRenderer_MouseMove(object sender, MouseEventArgs e)
        {
            if (e.Button == System.Windows.Forms.MouseButtons.Left)
            {
                SetMetaTile(e.Location);
            }
        }

        private void SetMetaTile(Point p)
        {
            if (this.track == null)
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
            int existingIndex = this.track.Layout.TileIndexAt(x, y);
            if (existingIndex == metaTileIndex)
            {
                return;
            }
            this.track.Layout.SetTileIndex(x, y, (byte)metaTileIndex);
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
    }
}
