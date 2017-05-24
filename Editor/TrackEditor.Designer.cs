namespace MicroMachinesEditor
{
    partial class TrackEditor
    {
        /// <summary> 
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary> 
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Component Designer generated code

        /// <summary> 
        /// Required method for Designer support - do not modify 
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(TrackEditor));
            this.toolStrip1 = new System.Windows.Forms.ToolStrip();
            this.btnTrackRotateUp = new System.Windows.Forms.ToolStripButton();
            this.btnTrackRotateDown = new System.Windows.Forms.ToolStripButton();
            this.btnTrackRotateLeft = new System.Windows.Forms.ToolStripButton();
            this.btnTrackRotateRight = new System.Windows.Forms.ToolStripButton();
            this.toolStripSeparator1 = new System.Windows.Forms.ToolStripSeparator();
            this.tbBlank = new System.Windows.Forms.ToolStripButton();
            this.toolStripSeparator3 = new System.Windows.Forms.ToolStripSeparator();
            this.tbGrid = new System.Windows.Forms.ToolStripButton();
            this.tbMetatileFlags = new System.Windows.Forms.ToolStripButton();
            this.tbTogglePositions = new System.Windows.Forms.ToolStripButton();
            this.tbEyeDropper = new System.Windows.Forms.ToolStripButton();
            this.splitContainer1 = new System.Windows.Forms.SplitContainer();
            this.statusStrip1 = new System.Windows.Forms.StatusStrip();
            this.mouseLocation = new System.Windows.Forms.ToolStripStatusLabel();
            this.scrollingPanel1 = new MicroMachinesEditor.ScrollingPanel();
            this.trackRenderer = new MicroMachinesEditor.TrackRenderer();
            this.metaTileSelector = new MicroMachinesEditor.MetaTileSelector();
            this.toolStrip1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer1)).BeginInit();
            this.splitContainer1.Panel1.SuspendLayout();
            this.splitContainer1.Panel2.SuspendLayout();
            this.splitContainer1.SuspendLayout();
            this.statusStrip1.SuspendLayout();
            this.scrollingPanel1.SuspendLayout();
            this.SuspendLayout();
            // 
            // toolStrip1
            // 
            this.toolStrip1.ImageScalingSize = new System.Drawing.Size(32, 32);
            this.toolStrip1.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.btnTrackRotateUp,
            this.btnTrackRotateDown,
            this.btnTrackRotateLeft,
            this.btnTrackRotateRight,
            this.toolStripSeparator1,
            this.tbBlank,
            this.toolStripSeparator3,
            this.tbGrid,
            this.tbMetatileFlags,
            this.tbTogglePositions,
            this.tbEyeDropper});
            this.toolStrip1.Location = new System.Drawing.Point(0, 0);
            this.toolStrip1.Name = "toolStrip1";
            this.toolStrip1.Padding = new System.Windows.Forms.Padding(0, 0, 2, 0);
            this.toolStrip1.Size = new System.Drawing.Size(1206, 39);
            this.toolStrip1.TabIndex = 6;
            this.toolStrip1.Text = "toolStrip1";
            // 
            // btnTrackRotateUp
            // 
            this.btnTrackRotateUp.DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle.Image;
            this.btnTrackRotateUp.Image = global::MicroMachinesEditor.Properties.Resources.UpArrow;
            this.btnTrackRotateUp.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.btnTrackRotateUp.Name = "btnTrackRotateUp";
            this.btnTrackRotateUp.Size = new System.Drawing.Size(36, 36);
            this.btnTrackRotateUp.Text = "Rotate map upwards";
            this.btnTrackRotateUp.Click += new System.EventHandler(this.btnTrackRotateUp_Click);
            // 
            // btnTrackRotateDown
            // 
            this.btnTrackRotateDown.DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle.Image;
            this.btnTrackRotateDown.Image = global::MicroMachinesEditor.Properties.Resources.DownArrow;
            this.btnTrackRotateDown.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.btnTrackRotateDown.Name = "btnTrackRotateDown";
            this.btnTrackRotateDown.Size = new System.Drawing.Size(36, 36);
            this.btnTrackRotateDown.Text = "Rotate map downwards";
            this.btnTrackRotateDown.Click += new System.EventHandler(this.btnTrackRotateDown_Click);
            // 
            // btnTrackRotateLeft
            // 
            this.btnTrackRotateLeft.DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle.Image;
            this.btnTrackRotateLeft.Image = global::MicroMachinesEditor.Properties.Resources.LeftArrow;
            this.btnTrackRotateLeft.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.btnTrackRotateLeft.Name = "btnTrackRotateLeft";
            this.btnTrackRotateLeft.Size = new System.Drawing.Size(36, 36);
            this.btnTrackRotateLeft.Text = "Rotate map left";
            this.btnTrackRotateLeft.Click += new System.EventHandler(this.btnTrackRotateLeft_Click);
            // 
            // btnTrackRotateRight
            // 
            this.btnTrackRotateRight.DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle.Image;
            this.btnTrackRotateRight.Image = global::MicroMachinesEditor.Properties.Resources.RightArrow;
            this.btnTrackRotateRight.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.btnTrackRotateRight.Name = "btnTrackRotateRight";
            this.btnTrackRotateRight.Size = new System.Drawing.Size(36, 36);
            this.btnTrackRotateRight.Text = "Rotate map right";
            this.btnTrackRotateRight.Click += new System.EventHandler(this.btnTrackRotateRight_Click);
            // 
            // toolStripSeparator1
            // 
            this.toolStripSeparator1.Name = "toolStripSeparator1";
            this.toolStripSeparator1.Size = new System.Drawing.Size(6, 39);
            // 
            // tbBlank
            // 
            this.tbBlank.DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle.Image;
            this.tbBlank.Image = global::MicroMachinesEditor.Properties.Resources.BlankPage;
            this.tbBlank.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.tbBlank.Name = "tbBlank";
            this.tbBlank.Size = new System.Drawing.Size(36, 36);
            this.tbBlank.Text = "Blank map";
            this.tbBlank.Click += new System.EventHandler(this.tbBlank_Click);
            // 
            // toolStripSeparator3
            // 
            this.toolStripSeparator3.Name = "toolStripSeparator3";
            this.toolStripSeparator3.Size = new System.Drawing.Size(6, 39);
            // 
            // tbGrid
            // 
            this.tbGrid.CheckOnClick = true;
            this.tbGrid.DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle.Image;
            this.tbGrid.Image = global::MicroMachinesEditor.Properties.Resources.Grid;
            this.tbGrid.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.tbGrid.Name = "tbGrid";
            this.tbGrid.Size = new System.Drawing.Size(36, 36);
            this.tbGrid.Text = "Show grid";
            this.tbGrid.Click += new System.EventHandler(this.tbGrid_Click);
            // 
            // tbMetatileFlags
            // 
            this.tbMetatileFlags.CheckOnClick = true;
            this.tbMetatileFlags.DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle.Image;
            this.tbMetatileFlags.Image = ((System.Drawing.Image)(resources.GetObject("tbMetatileFlags.Image")));
            this.tbMetatileFlags.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.tbMetatileFlags.Name = "tbMetatileFlags";
            this.tbMetatileFlags.Size = new System.Drawing.Size(36, 36);
            this.tbMetatileFlags.Text = "toolStripButton1";
            this.tbMetatileFlags.Click += new System.EventHandler(this.tbMetatileFlags_Click);
            // 
            // tbTogglePositions
            // 
            this.tbTogglePositions.CheckOnClick = true;
            this.tbTogglePositions.DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle.Image;
            this.tbTogglePositions.Image = global::MicroMachinesEditor.Properties.Resources._123;
            this.tbTogglePositions.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.tbTogglePositions.Name = "tbTogglePositions";
            this.tbTogglePositions.Size = new System.Drawing.Size(36, 36);
            this.tbTogglePositions.Text = "Show track positions";
            this.tbTogglePositions.Click += new System.EventHandler(this.tbTogglePositions_Click);
            // 
            // tbEyeDropper
            // 
            this.tbEyeDropper.CheckOnClick = true;
            this.tbEyeDropper.DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle.Image;
            this.tbEyeDropper.Image = global::MicroMachinesEditor.Properties.Resources.EyeDropper;
            this.tbEyeDropper.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.tbEyeDropper.Name = "tbEyeDropper";
            this.tbEyeDropper.Size = new System.Drawing.Size(36, 36);
            this.tbEyeDropper.Text = "Tile eyedropper (Ctrl+click)";
            // 
            // splitContainer1
            // 
            this.splitContainer1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.splitContainer1.Location = new System.Drawing.Point(0, 39);
            this.splitContainer1.Margin = new System.Windows.Forms.Padding(6);
            this.splitContainer1.Name = "splitContainer1";
            // 
            // splitContainer1.Panel1
            // 
            this.splitContainer1.Panel1.Controls.Add(this.scrollingPanel1);
            // 
            // splitContainer1.Panel2
            // 
            this.splitContainer1.Panel2.Controls.Add(this.metaTileSelector);
            this.splitContainer1.Size = new System.Drawing.Size(1206, 593);
            this.splitContainer1.SplitterDistance = 877;
            this.splitContainer1.SplitterWidth = 8;
            this.splitContainer1.TabIndex = 7;
            // 
            // statusStrip1
            // 
            this.statusStrip1.ImageScalingSize = new System.Drawing.Size(32, 32);
            this.statusStrip1.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.mouseLocation});
            this.statusStrip1.Location = new System.Drawing.Point(0, 632);
            this.statusStrip1.Name = "statusStrip1";
            this.statusStrip1.Size = new System.Drawing.Size(1206, 37);
            this.statusStrip1.TabIndex = 8;
            this.statusStrip1.Text = "statusStrip1";
            // 
            // mouseLocation
            // 
            this.mouseLocation.Name = "mouseLocation";
            this.mouseLocation.Size = new System.Drawing.Size(53, 32);
            this.mouseLocation.Text = "0, 0";
            // 
            // scrollingPanel1
            // 
            this.scrollingPanel1.AutoScroll = true;
            this.scrollingPanel1.Controls.Add(this.trackRenderer);
            this.scrollingPanel1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.scrollingPanel1.Location = new System.Drawing.Point(0, 0);
            this.scrollingPanel1.Margin = new System.Windows.Forms.Padding(6);
            this.scrollingPanel1.Name = "scrollingPanel1";
            this.scrollingPanel1.Size = new System.Drawing.Size(877, 593);
            this.scrollingPanel1.TabIndex = 1;
            // 
            // trackRenderer
            // 
            this.trackRenderer.Location = new System.Drawing.Point(0, 0);
            this.trackRenderer.Margin = new System.Windows.Forms.Padding(12);
            this.trackRenderer.MaximumSize = new System.Drawing.Size(6144, 5908);
            this.trackRenderer.MetaTiles = null;
            this.trackRenderer.MinimumSize = new System.Drawing.Size(6144, 5908);
            this.trackRenderer.Name = "trackRenderer";
            this.trackRenderer.ShowGrid = false;
            this.trackRenderer.ShowMetaTileFlags = false;
            this.trackRenderer.ShowPositions = false;
            this.trackRenderer.Size = new System.Drawing.Size(6144, 5908);
            this.trackRenderer.TabIndex = 0;
            this.trackRenderer.TrackLayout = null;
            this.trackRenderer.MouseDown += new System.Windows.Forms.MouseEventHandler(this.trackRenderer_MouseDown);
            this.trackRenderer.MouseMove += new System.Windows.Forms.MouseEventHandler(this.trackRenderer_MouseMove);
            // 
            // metaTileSelector
            // 
            this.metaTileSelector.AutoScroll = true;
            this.metaTileSelector.Dock = System.Windows.Forms.DockStyle.Fill;
            this.metaTileSelector.Location = new System.Drawing.Point(0, 0);
            this.metaTileSelector.Margin = new System.Windows.Forms.Padding(6);
            this.metaTileSelector.MetaTiles = null;
            this.metaTileSelector.Name = "metaTileSelector";
            this.metaTileSelector.SelectedMetaTileIndex = -1;
            this.metaTileSelector.Size = new System.Drawing.Size(321, 593);
            this.metaTileSelector.TabIndex = 1;
            this.metaTileSelector.OnHover += new System.EventHandler<int>(this.metaTileSelector_OnHover);
            // 
            // TrackEditor
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(12F, 25F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.splitContainer1);
            this.Controls.Add(this.toolStrip1);
            this.Controls.Add(this.statusStrip1);
            this.Margin = new System.Windows.Forms.Padding(6);
            this.Name = "TrackEditor";
            this.Size = new System.Drawing.Size(1206, 669);
            this.toolStrip1.ResumeLayout(false);
            this.toolStrip1.PerformLayout();
            this.splitContainer1.Panel1.ResumeLayout(false);
            this.splitContainer1.Panel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer1)).EndInit();
            this.splitContainer1.ResumeLayout(false);
            this.statusStrip1.ResumeLayout(false);
            this.statusStrip1.PerformLayout();
            this.scrollingPanel1.ResumeLayout(false);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.ToolStrip toolStrip1;
        private System.Windows.Forms.ToolStripButton tbBlank;
        private System.Windows.Forms.ToolStripButton btnTrackRotateUp;
        private System.Windows.Forms.ToolStripButton btnTrackRotateDown;
        private System.Windows.Forms.ToolStripButton btnTrackRotateLeft;
        private System.Windows.Forms.ToolStripButton btnTrackRotateRight;
        private System.Windows.Forms.ToolStripSeparator toolStripSeparator1;
        private System.Windows.Forms.ToolStripButton tbGrid;
        private System.Windows.Forms.ToolStripSeparator toolStripSeparator3;
        private System.Windows.Forms.SplitContainer splitContainer1;
        private TrackRenderer trackRenderer;
        private ScrollingPanel scrollingPanel1;
        private System.Windows.Forms.ToolStripButton tbTogglePositions;
        private System.Windows.Forms.ToolStripButton tbEyeDropper;
        private System.Windows.Forms.ToolStripButton tbMetatileFlags;
        private MetaTileSelector metaTileSelector;
        private System.Windows.Forms.StatusStrip statusStrip1;
        private System.Windows.Forms.ToolStripStatusLabel mouseLocation;
    }
}
