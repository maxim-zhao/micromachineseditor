namespace MicroMachinesEditor
{
    partial class MainForm
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

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.components = new System.ComponentModel.Container();
            this.tbFilename = new System.Windows.Forms.TextBox();
            this.tbOffset = new System.Windows.Forms.TextBox();
            this.tbOutput = new System.Windows.Forms.TextBox();
            this.btnDecode = new System.Windows.Forms.Button();
            this.tbLog = new System.Windows.Forms.TextBox();
            this.statusStrip1 = new System.Windows.Forms.StatusStrip();
            this.toolStripStatusLabel1 = new System.Windows.Forms.ToolStripStatusLabel();
            this.btnSearch = new System.Windows.Forms.Button();
            this.tabControl1 = new System.Windows.Forms.TabControl();
            this.tabTrackList = new System.Windows.Forms.TabPage();
            this.pgTrack = new System.Windows.Forms.PropertyGrid();
            this.lvTracks = new System.Windows.Forms.ListView();
            this.trackListMenu = new System.Windows.Forms.ContextMenuStrip(this.components);
            this.editTrackToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.tabTrack = new System.Windows.Forms.TabPage();
            this.trackEditor = new MicroMachinesEditor.TrackEditor();
            this.tabMetaTiles = new System.Windows.Forms.TabPage();
            this.panelMetaTiles = new System.Windows.Forms.Panel();
            this.pbMetaTiles = new System.Windows.Forms.PictureBox();
            this.tabTiles = new System.Windows.Forms.TabPage();
            this.panelTiles = new System.Windows.Forms.Panel();
            this.pbTiles = new System.Windows.Forms.PictureBox();
            this.tabPalette = new System.Windows.Forms.TabPage();
            this.pbPalette = new System.Windows.Forms.PictureBox();
            this.tabRaw = new System.Windows.Forms.TabPage();
            this.btnText = new System.Windows.Forms.Button();
            this.nudStageIndex = new System.Windows.Forms.NumericUpDown();
            this.cbLevelType = new System.Windows.Forms.ComboBox();
            this.statusStrip1.SuspendLayout();
            this.tabControl1.SuspendLayout();
            this.tabTrackList.SuspendLayout();
            this.trackListMenu.SuspendLayout();
            this.tabTrack.SuspendLayout();
            this.tabMetaTiles.SuspendLayout();
            this.panelMetaTiles.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.pbMetaTiles)).BeginInit();
            this.tabTiles.SuspendLayout();
            this.panelTiles.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.pbTiles)).BeginInit();
            this.tabPalette.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.pbPalette)).BeginInit();
            this.tabRaw.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.nudStageIndex)).BeginInit();
            this.SuspendLayout();
            // 
            // tbFilename
            // 
            this.tbFilename.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.tbFilename.Location = new System.Drawing.Point(13, 13);
            this.tbFilename.Name = "tbFilename";
            this.tbFilename.Size = new System.Drawing.Size(763, 20);
            this.tbFilename.TabIndex = 0;
            this.tbFilename.Text = "C:\\Users\\Maxim\\Documents\\Roms\\Micro Machines.sms";
            // 
            // tbOffset
            // 
            this.tbOffset.Location = new System.Drawing.Point(6, 6);
            this.tbOffset.Name = "tbOffset";
            this.tbOffset.Size = new System.Drawing.Size(100, 20);
            this.tbOffset.TabIndex = 0;
            this.tbOffset.Text = "3d901";
            // 
            // tbOutput
            // 
            this.tbOutput.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.tbOutput.Font = new System.Drawing.Font("Consolas", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.tbOutput.Location = new System.Drawing.Point(6, 33);
            this.tbOutput.Multiline = true;
            this.tbOutput.Name = "tbOutput";
            this.tbOutput.ReadOnly = true;
            this.tbOutput.ScrollBars = System.Windows.Forms.ScrollBars.Vertical;
            this.tbOutput.Size = new System.Drawing.Size(744, 85);
            this.tbOutput.TabIndex = 4;
            // 
            // btnDecode
            // 
            this.btnDecode.Location = new System.Drawing.Point(112, 4);
            this.btnDecode.Name = "btnDecode";
            this.btnDecode.Size = new System.Drawing.Size(75, 23);
            this.btnDecode.TabIndex = 1;
            this.btnDecode.Text = "Decode";
            this.btnDecode.UseVisualStyleBackColor = true;
            this.btnDecode.Click += new System.EventHandler(this.btnDecode_Click);
            // 
            // tbLog
            // 
            this.tbLog.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.tbLog.Font = new System.Drawing.Font("Consolas", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.tbLog.Location = new System.Drawing.Point(6, 124);
            this.tbLog.Multiline = true;
            this.tbLog.Name = "tbLog";
            this.tbLog.ReadOnly = true;
            this.tbLog.ScrollBars = System.Windows.Forms.ScrollBars.Vertical;
            this.tbLog.Size = new System.Drawing.Size(744, 130);
            this.tbLog.TabIndex = 0;
            // 
            // statusStrip1
            // 
            this.statusStrip1.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.toolStripStatusLabel1});
            this.statusStrip1.Location = new System.Drawing.Point(0, 355);
            this.statusStrip1.Name = "statusStrip1";
            this.statusStrip1.Size = new System.Drawing.Size(788, 22);
            this.statusStrip1.TabIndex = 5;
            this.statusStrip1.Text = "statusStrip1";
            // 
            // toolStripStatusLabel1
            // 
            this.toolStripStatusLabel1.Name = "toolStripStatusLabel1";
            this.toolStripStatusLabel1.Size = new System.Drawing.Size(39, 17);
            this.toolStripStatusLabel1.Text = "Ready";
            // 
            // btnSearch
            // 
            this.btnSearch.Location = new System.Drawing.Point(193, 4);
            this.btnSearch.Name = "btnSearch";
            this.btnSearch.Size = new System.Drawing.Size(75, 23);
            this.btnSearch.TabIndex = 2;
            this.btnSearch.Text = "Search";
            this.btnSearch.UseVisualStyleBackColor = true;
            this.btnSearch.Click += new System.EventHandler(this.btnSearch_Click);
            // 
            // tabControl1
            // 
            this.tabControl1.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.tabControl1.Controls.Add(this.tabTrackList);
            this.tabControl1.Controls.Add(this.tabTrack);
            this.tabControl1.Controls.Add(this.tabMetaTiles);
            this.tabControl1.Controls.Add(this.tabTiles);
            this.tabControl1.Controls.Add(this.tabPalette);
            this.tabControl1.Controls.Add(this.tabRaw);
            this.tabControl1.Location = new System.Drawing.Point(12, 66);
            this.tabControl1.Name = "tabControl1";
            this.tabControl1.SelectedIndex = 0;
            this.tabControl1.Size = new System.Drawing.Size(764, 286);
            this.tabControl1.TabIndex = 3;
            // 
            // tabTrackList
            // 
            this.tabTrackList.Controls.Add(this.pgTrack);
            this.tabTrackList.Controls.Add(this.lvTracks);
            this.tabTrackList.Location = new System.Drawing.Point(4, 22);
            this.tabTrackList.Name = "tabTrackList";
            this.tabTrackList.Padding = new System.Windows.Forms.Padding(3);
            this.tabTrackList.Size = new System.Drawing.Size(756, 260);
            this.tabTrackList.TabIndex = 9;
            this.tabTrackList.Text = "Track list";
            this.tabTrackList.UseVisualStyleBackColor = true;
            // 
            // pgTrack
            // 
            this.pgTrack.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.pgTrack.HelpVisible = false;
            this.pgTrack.Location = new System.Drawing.Point(487, 6);
            this.pgTrack.Name = "pgTrack";
            this.pgTrack.PropertySort = System.Windows.Forms.PropertySort.Alphabetical;
            this.pgTrack.Size = new System.Drawing.Size(263, 248);
            this.pgTrack.TabIndex = 1;
            this.pgTrack.ToolbarVisible = false;
            // 
            // lvTracks
            // 
            this.lvTracks.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.lvTracks.ContextMenuStrip = this.trackListMenu;
            this.lvTracks.HideSelection = false;
            this.lvTracks.Location = new System.Drawing.Point(6, 6);
            this.lvTracks.Name = "lvTracks";
            this.lvTracks.Size = new System.Drawing.Size(475, 248);
            this.lvTracks.TabIndex = 0;
            this.lvTracks.UseCompatibleStateImageBehavior = false;
            this.lvTracks.SelectedIndexChanged += new System.EventHandler(this.lvTracks_SelectedIndexChanged);
            // 
            // trackListMenu
            // 
            this.trackListMenu.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.editTrackToolStripMenuItem});
            this.trackListMenu.Name = "trackListMenu";
            this.trackListMenu.Size = new System.Drawing.Size(124, 26);
            // 
            // editTrackToolStripMenuItem
            // 
            this.editTrackToolStripMenuItem.Name = "editTrackToolStripMenuItem";
            this.editTrackToolStripMenuItem.Size = new System.Drawing.Size(123, 22);
            this.editTrackToolStripMenuItem.Text = "Edit track";
            this.editTrackToolStripMenuItem.Click += new System.EventHandler(this.editTrackToolStripMenuItem_Click);
            // 
            // tabTrack
            // 
            this.tabTrack.Controls.Add(this.trackEditor);
            this.tabTrack.Location = new System.Drawing.Point(4, 22);
            this.tabTrack.Name = "tabTrack";
            this.tabTrack.Padding = new System.Windows.Forms.Padding(3);
            this.tabTrack.Size = new System.Drawing.Size(756, 260);
            this.tabTrack.TabIndex = 4;
            this.tabTrack.Text = "Track";
            this.tabTrack.UseVisualStyleBackColor = true;
            // 
            // trackEditor
            // 
            this.trackEditor.Dock = System.Windows.Forms.DockStyle.Fill;
            this.trackEditor.Location = new System.Drawing.Point(3, 3);
            this.trackEditor.Name = "trackEditor";
            this.trackEditor.Size = new System.Drawing.Size(750, 254);
            this.trackEditor.TabIndex = 0;
            this.trackEditor.Track = null;
            // 
            // tabMetaTiles
            // 
            this.tabMetaTiles.Controls.Add(this.panelMetaTiles);
            this.tabMetaTiles.Location = new System.Drawing.Point(4, 22);
            this.tabMetaTiles.Name = "tabMetaTiles";
            this.tabMetaTiles.Padding = new System.Windows.Forms.Padding(3);
            this.tabMetaTiles.Size = new System.Drawing.Size(756, 260);
            this.tabMetaTiles.TabIndex = 7;
            this.tabMetaTiles.Text = "Metatiles";
            this.tabMetaTiles.UseVisualStyleBackColor = true;
            // 
            // panelMetaTiles
            // 
            this.panelMetaTiles.AutoScroll = true;
            this.panelMetaTiles.Controls.Add(this.pbMetaTiles);
            this.panelMetaTiles.Dock = System.Windows.Forms.DockStyle.Fill;
            this.panelMetaTiles.Location = new System.Drawing.Point(3, 3);
            this.panelMetaTiles.Name = "panelMetaTiles";
            this.panelMetaTiles.Size = new System.Drawing.Size(750, 254);
            this.panelMetaTiles.TabIndex = 4;
            // 
            // pbMetaTiles
            // 
            this.pbMetaTiles.Location = new System.Drawing.Point(0, 0);
            this.pbMetaTiles.Name = "pbMetaTiles";
            this.pbMetaTiles.Size = new System.Drawing.Size(96, 96);
            this.pbMetaTiles.SizeMode = System.Windows.Forms.PictureBoxSizeMode.AutoSize;
            this.pbMetaTiles.TabIndex = 3;
            this.pbMetaTiles.TabStop = false;
            // 
            // tabTiles
            // 
            this.tabTiles.Controls.Add(this.panelTiles);
            this.tabTiles.Location = new System.Drawing.Point(4, 22);
            this.tabTiles.Name = "tabTiles";
            this.tabTiles.Padding = new System.Windows.Forms.Padding(3);
            this.tabTiles.Size = new System.Drawing.Size(756, 260);
            this.tabTiles.TabIndex = 6;
            this.tabTiles.Text = "Tiles";
            this.tabTiles.UseVisualStyleBackColor = true;
            // 
            // panelTiles
            // 
            this.panelTiles.AutoScroll = true;
            this.panelTiles.Controls.Add(this.pbTiles);
            this.panelTiles.Dock = System.Windows.Forms.DockStyle.Fill;
            this.panelTiles.Location = new System.Drawing.Point(3, 3);
            this.panelTiles.Name = "panelTiles";
            this.panelTiles.Size = new System.Drawing.Size(750, 254);
            this.panelTiles.TabIndex = 3;
            // 
            // pbTiles
            // 
            this.pbTiles.Location = new System.Drawing.Point(0, 0);
            this.pbTiles.Name = "pbTiles";
            this.pbTiles.Size = new System.Drawing.Size(768, 768);
            this.pbTiles.SizeMode = System.Windows.Forms.PictureBoxSizeMode.AutoSize;
            this.pbTiles.TabIndex = 2;
            this.pbTiles.TabStop = false;
            // 
            // tabPalette
            // 
            this.tabPalette.Controls.Add(this.pbPalette);
            this.tabPalette.Location = new System.Drawing.Point(4, 22);
            this.tabPalette.Name = "tabPalette";
            this.tabPalette.Padding = new System.Windows.Forms.Padding(3);
            this.tabPalette.Size = new System.Drawing.Size(756, 260);
            this.tabPalette.TabIndex = 5;
            this.tabPalette.Text = "Palette";
            this.tabPalette.UseVisualStyleBackColor = true;
            // 
            // pbPalette
            // 
            this.pbPalette.Dock = System.Windows.Forms.DockStyle.Top;
            this.pbPalette.Location = new System.Drawing.Point(3, 3);
            this.pbPalette.Name = "pbPalette";
            this.pbPalette.Size = new System.Drawing.Size(750, 50);
            this.pbPalette.SizeMode = System.Windows.Forms.PictureBoxSizeMode.StretchImage;
            this.pbPalette.TabIndex = 0;
            this.pbPalette.TabStop = false;
            // 
            // tabRaw
            // 
            this.tabRaw.Controls.Add(this.btnText);
            this.tabRaw.Controls.Add(this.tbOffset);
            this.tabRaw.Controls.Add(this.btnSearch);
            this.tabRaw.Controls.Add(this.tbOutput);
            this.tabRaw.Controls.Add(this.btnDecode);
            this.tabRaw.Controls.Add(this.tbLog);
            this.tabRaw.Location = new System.Drawing.Point(4, 22);
            this.tabRaw.Name = "tabRaw";
            this.tabRaw.Padding = new System.Windows.Forms.Padding(3);
            this.tabRaw.Size = new System.Drawing.Size(756, 260);
            this.tabRaw.TabIndex = 0;
            this.tabRaw.Text = "Raw";
            this.tabRaw.UseVisualStyleBackColor = true;
            // 
            // btnText
            // 
            this.btnText.Location = new System.Drawing.Point(274, 4);
            this.btnText.Name = "btnText";
            this.btnText.Size = new System.Drawing.Size(75, 23);
            this.btnText.TabIndex = 3;
            this.btnText.Text = "Text";
            this.btnText.UseVisualStyleBackColor = true;
            this.btnText.Click += new System.EventHandler(this.btnText_Click);
            // 
            // nudStageIndex
            // 
            this.nudStageIndex.Location = new System.Drawing.Point(139, 39);
            this.nudStageIndex.Maximum = new decimal(new int[] {
            3,
            0,
            0,
            0});
            this.nudStageIndex.Name = "nudStageIndex";
            this.nudStageIndex.Size = new System.Drawing.Size(48, 20);
            this.nudStageIndex.TabIndex = 2;
            this.nudStageIndex.ValueChanged += new System.EventHandler(this.TrackParametersChanged);
            // 
            // cbLevelType
            // 
            this.cbLevelType.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.cbLevelType.FormattingEnabled = true;
            this.cbLevelType.Items.AddRange(new object[] {
            "Desk/sportscars",
            "Breakfast table/four by four",
            "Bathtub/powerboats",
            "Sandpit/turbo wheels",
            "Pool table/formula one",
            "Garage/warriors",
            "Bedroom/tanks",
            "Bonus stage/Rufftrux"});
            this.cbLevelType.Location = new System.Drawing.Point(12, 39);
            this.cbLevelType.Name = "cbLevelType";
            this.cbLevelType.Size = new System.Drawing.Size(121, 21);
            this.cbLevelType.TabIndex = 1;
            this.cbLevelType.SelectedIndexChanged += new System.EventHandler(this.TrackParametersChanged);
            // 
            // MainForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(788, 377);
            this.Controls.Add(this.tabControl1);
            this.Controls.Add(this.nudStageIndex);
            this.Controls.Add(this.statusStrip1);
            this.Controls.Add(this.cbLevelType);
            this.Controls.Add(this.tbFilename);
            this.Name = "MainForm";
            this.Text = "Micro Machines Editor";
            this.Load += new System.EventHandler(this.Form1_Load);
            this.statusStrip1.ResumeLayout(false);
            this.statusStrip1.PerformLayout();
            this.tabControl1.ResumeLayout(false);
            this.tabTrackList.ResumeLayout(false);
            this.trackListMenu.ResumeLayout(false);
            this.tabTrack.ResumeLayout(false);
            this.tabMetaTiles.ResumeLayout(false);
            this.panelMetaTiles.ResumeLayout(false);
            this.panelMetaTiles.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.pbMetaTiles)).EndInit();
            this.tabTiles.ResumeLayout(false);
            this.panelTiles.ResumeLayout(false);
            this.panelTiles.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.pbTiles)).EndInit();
            this.tabPalette.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.pbPalette)).EndInit();
            this.tabRaw.ResumeLayout(false);
            this.tabRaw.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.nudStageIndex)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.TextBox tbFilename;
        private System.Windows.Forms.TextBox tbOffset;
        private System.Windows.Forms.TextBox tbOutput;
        private System.Windows.Forms.Button btnDecode;
        private System.Windows.Forms.TextBox tbLog;
        private System.Windows.Forms.StatusStrip statusStrip1;
        private System.Windows.Forms.ToolStripStatusLabel toolStripStatusLabel1;
        private System.Windows.Forms.Button btnSearch;
        private System.Windows.Forms.TabControl tabControl1;
        private System.Windows.Forms.TabPage tabRaw;
        private System.Windows.Forms.NumericUpDown nudStageIndex;
        private System.Windows.Forms.ComboBox cbLevelType;
        private System.Windows.Forms.TabPage tabTrack;
        private System.Windows.Forms.TabPage tabPalette;
        private System.Windows.Forms.PictureBox pbPalette;
        private System.Windows.Forms.TabPage tabTiles;
        private System.Windows.Forms.Panel panelTiles;
        private System.Windows.Forms.PictureBox pbTiles;
        private System.Windows.Forms.TabPage tabMetaTiles;
        private System.Windows.Forms.Panel panelMetaTiles;
        private System.Windows.Forms.PictureBox pbMetaTiles;
        private System.Windows.Forms.Button btnText;
        private System.Windows.Forms.TabPage tabTrackList;
        private System.Windows.Forms.ListView lvTracks;
        private System.Windows.Forms.PropertyGrid pgTrack;
        private System.Windows.Forms.ContextMenuStrip trackListMenu;
        private System.Windows.Forms.ToolStripMenuItem editTrackToolStripMenuItem;
        private TrackEditor trackEditor;
    }
}

