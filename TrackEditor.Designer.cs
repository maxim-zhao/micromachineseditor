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
            this.tbTogglePositions = new System.Windows.Forms.ToolStripButton();
            this.tbEyeDropper = new System.Windows.Forms.ToolStripButton();
            this.splitContainer1 = new System.Windows.Forms.SplitContainer();
            this.scrollingPanel1 = new MicroMachinesEditor.ScrollingPanel();
            this.trackRenderer = new MicroMachinesEditor.TrackRenderer();
            this.scrollingPanel2 = new MicroMachinesEditor.ScrollingPanel();
            this.metaTileSelector = new MicroMachinesEditor.MetaTileSelector();
            this.tbMetatileFlags = new System.Windows.Forms.ToolStripButton();
            this.toolStrip1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer1)).BeginInit();
            this.splitContainer1.Panel1.SuspendLayout();
            this.splitContainer1.Panel2.SuspendLayout();
            this.splitContainer1.SuspendLayout();
            this.scrollingPanel1.SuspendLayout();
            this.scrollingPanel2.SuspendLayout();
            this.SuspendLayout();
            // 
            // toolStrip1
            // 
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
            this.toolStrip1.Size = new System.Drawing.Size(793, 25);
            this.toolStrip1.TabIndex = 6;
            this.toolStrip1.Text = "toolStrip1";
            // 
            // btnTrackRotateUp
            // 
            this.btnTrackRotateUp.DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle.Image;
            this.btnTrackRotateUp.Image = global::MicroMachinesEditor.Properties.Resources.UpArrow;
            this.btnTrackRotateUp.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.btnTrackRotateUp.Name = "btnTrackRotateUp";
            this.btnTrackRotateUp.Size = new System.Drawing.Size(23, 22);
            this.btnTrackRotateUp.Text = "Rotate map upwards";
            this.btnTrackRotateUp.Click += new System.EventHandler(this.btnTrackRotateUp_Click);
            // 
            // btnTrackRotateDown
            // 
            this.btnTrackRotateDown.DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle.Image;
            this.btnTrackRotateDown.Image = global::MicroMachinesEditor.Properties.Resources.DownArrow;
            this.btnTrackRotateDown.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.btnTrackRotateDown.Name = "btnTrackRotateDown";
            this.btnTrackRotateDown.Size = new System.Drawing.Size(23, 22);
            this.btnTrackRotateDown.Text = "Rotate map downwards";
            this.btnTrackRotateDown.Click += new System.EventHandler(this.btnTrackRotateDown_Click);
            // 
            // btnTrackRotateLeft
            // 
            this.btnTrackRotateLeft.DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle.Image;
            this.btnTrackRotateLeft.Image = global::MicroMachinesEditor.Properties.Resources.LeftArrow;
            this.btnTrackRotateLeft.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.btnTrackRotateLeft.Name = "btnTrackRotateLeft";
            this.btnTrackRotateLeft.Size = new System.Drawing.Size(23, 22);
            this.btnTrackRotateLeft.Text = "Rotate map left";
            this.btnTrackRotateLeft.Click += new System.EventHandler(this.btnTrackRotateLeft_Click);
            // 
            // btnTrackRotateRight
            // 
            this.btnTrackRotateRight.DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle.Image;
            this.btnTrackRotateRight.Image = global::MicroMachinesEditor.Properties.Resources.RightArrow;
            this.btnTrackRotateRight.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.btnTrackRotateRight.Name = "btnTrackRotateRight";
            this.btnTrackRotateRight.Size = new System.Drawing.Size(23, 22);
            this.btnTrackRotateRight.Text = "Rotate map right";
            this.btnTrackRotateRight.Click += new System.EventHandler(this.btnTrackRotateRight_Click);
            // 
            // toolStripSeparator1
            // 
            this.toolStripSeparator1.Name = "toolStripSeparator1";
            this.toolStripSeparator1.Size = new System.Drawing.Size(6, 25);
            // 
            // tbBlank
            // 
            this.tbBlank.DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle.Image;
            this.tbBlank.Image = global::MicroMachinesEditor.Properties.Resources.BlankPage;
            this.tbBlank.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.tbBlank.Name = "tbBlank";
            this.tbBlank.Size = new System.Drawing.Size(23, 22);
            this.tbBlank.Text = "Blank map";
            this.tbBlank.Click += new System.EventHandler(this.tbBlank_Click);
            // 
            // toolStripSeparator3
            // 
            this.toolStripSeparator3.Name = "toolStripSeparator3";
            this.toolStripSeparator3.Size = new System.Drawing.Size(6, 25);
            // 
            // tbGrid
            // 
            this.tbGrid.CheckOnClick = true;
            this.tbGrid.DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle.Image;
            this.tbGrid.Image = global::MicroMachinesEditor.Properties.Resources.Grid;
            this.tbGrid.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.tbGrid.Name = "tbGrid";
            this.tbGrid.Size = new System.Drawing.Size(23, 22);
            this.tbGrid.Text = "Show grid";
            this.tbGrid.Click += new System.EventHandler(this.tbGrid_Click);
            // 
            // tbTogglePositions
            // 
            this.tbTogglePositions.CheckOnClick = true;
            this.tbTogglePositions.DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle.Image;
            this.tbTogglePositions.Image = global::MicroMachinesEditor.Properties.Resources._123;
            this.tbTogglePositions.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.tbTogglePositions.Name = "tbTogglePositions";
            this.tbTogglePositions.Size = new System.Drawing.Size(23, 22);
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
            this.tbEyeDropper.Size = new System.Drawing.Size(23, 22);
            this.tbEyeDropper.Text = "Tile eyedropper (Ctrl+click)";
            // 
            // splitContainer1
            // 
            this.splitContainer1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.splitContainer1.Location = new System.Drawing.Point(0, 25);
            this.splitContainer1.Name = "splitContainer1";
            // 
            // splitContainer1.Panel1
            // 
            this.splitContainer1.Panel1.Controls.Add(this.scrollingPanel1);
            // 
            // splitContainer1.Panel2
            // 
            this.splitContainer1.Panel2.Controls.Add(this.scrollingPanel2);
            this.splitContainer1.Size = new System.Drawing.Size(793, 427);
            this.splitContainer1.SplitterDistance = 577;
            this.splitContainer1.TabIndex = 7;
            // 
            // scrollingPanel1
            // 
            this.scrollingPanel1.AutoScroll = true;
            this.scrollingPanel1.Controls.Add(this.trackRenderer);
            this.scrollingPanel1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.scrollingPanel1.Location = new System.Drawing.Point(0, 0);
            this.scrollingPanel1.Name = "scrollingPanel1";
            this.scrollingPanel1.Size = new System.Drawing.Size(577, 427);
            this.scrollingPanel1.TabIndex = 1;
            // 
            // trackRenderer
            // 
            this.trackRenderer.Location = new System.Drawing.Point(0, 0);
            this.trackRenderer.MaximumSize = new System.Drawing.Size(3072, 3072);
            this.trackRenderer.MetaTiles = null;
            this.trackRenderer.MinimumSize = new System.Drawing.Size(3072, 3072);
            this.trackRenderer.Name = "trackRenderer";
            this.trackRenderer.ShowGrid = false;
            this.trackRenderer.ShowPositions = false;
            this.trackRenderer.Size = new System.Drawing.Size(3072, 3072);
            this.trackRenderer.TabIndex = 0;
            this.trackRenderer.TrackLayout = null;
            this.trackRenderer.MouseDown += new System.Windows.Forms.MouseEventHandler(this.trackRenderer_MouseDown);
            this.trackRenderer.MouseMove += new System.Windows.Forms.MouseEventHandler(this.trackRenderer_MouseMove);
            // 
            // scrollingPanel2
            // 
            this.scrollingPanel2.AutoScroll = true;
            this.scrollingPanel2.Controls.Add(this.metaTileSelector);
            this.scrollingPanel2.Dock = System.Windows.Forms.DockStyle.Fill;
            this.scrollingPanel2.Location = new System.Drawing.Point(0, 0);
            this.scrollingPanel2.Name = "scrollingPanel2";
            this.scrollingPanel2.Size = new System.Drawing.Size(212, 427);
            this.scrollingPanel2.TabIndex = 1;
            // 
            // metaTileSelector
            // 
            this.metaTileSelector.AutoSize = true;
            this.metaTileSelector.AutoSizeMode = System.Windows.Forms.AutoSizeMode.GrowAndShrink;
            this.metaTileSelector.Dock = System.Windows.Forms.DockStyle.Top;
            this.metaTileSelector.Location = new System.Drawing.Point(0, 0);
            this.metaTileSelector.MetaTiles = null;
            this.metaTileSelector.Name = "metaTileSelector";
            this.metaTileSelector.SelectedMetaTileIndex = 0;
            this.metaTileSelector.Size = new System.Drawing.Size(212, 96);
            this.metaTileSelector.TabIndex = 0;
            // 
            // tbMetatileFlags
            // 
            this.tbMetatileFlags.CheckOnClick = true;
            this.tbMetatileFlags.DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle.Image;
            this.tbMetatileFlags.Image = ((System.Drawing.Image)(resources.GetObject("tbMetatileFlags.Image")));
            this.tbMetatileFlags.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.tbMetatileFlags.Name = "tbMetatileFlags";
            this.tbMetatileFlags.Size = new System.Drawing.Size(23, 22);
            this.tbMetatileFlags.Text = "toolStripButton1";
            this.tbMetatileFlags.Click += new System.EventHandler(this.tbMetatileFlags_Click);
            // 
            // TrackEditor
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.splitContainer1);
            this.Controls.Add(this.toolStrip1);
            this.Name = "TrackEditor";
            this.Size = new System.Drawing.Size(793, 452);
            this.toolStrip1.ResumeLayout(false);
            this.toolStrip1.PerformLayout();
            this.splitContainer1.Panel1.ResumeLayout(false);
            this.splitContainer1.Panel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer1)).EndInit();
            this.splitContainer1.ResumeLayout(false);
            this.scrollingPanel1.ResumeLayout(false);
            this.scrollingPanel2.ResumeLayout(false);
            this.scrollingPanel2.PerformLayout();
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
        private MetaTileSelector metaTileSelector;
        private ScrollingPanel scrollingPanel1;
        private ScrollingPanel scrollingPanel2;
        private System.Windows.Forms.ToolStripButton tbTogglePositions;
        private System.Windows.Forms.ToolStripButton tbEyeDropper;
        private System.Windows.Forms.ToolStripButton tbMetatileFlags;
    }
}
