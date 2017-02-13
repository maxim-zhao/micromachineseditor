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
            this.statusStrip1 = new System.Windows.Forms.StatusStrip();
            this.toolStripStatusLabel1 = new System.Windows.Forms.ToolStripStatusLabel();
            this.btnSearch = new System.Windows.Forms.Button();
            this.tabControl1 = new System.Windows.Forms.TabControl();
            this.tabTrackList = new System.Windows.Forms.TabPage();
            this.splitContainer1 = new System.Windows.Forms.SplitContainer();
            this.lvTracks = new System.Windows.Forms.ListView();
            this.trackListMenu = new System.Windows.Forms.ContextMenuStrip(this.components);
            this.editTrackToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.pgTrack = new System.Windows.Forms.PropertyGrid();
            this.tabTrack = new System.Windows.Forms.TabPage();
            this.tabMetaTiles = new System.Windows.Forms.TabPage();
            this.panelMetaTiles = new System.Windows.Forms.Panel();
            this.pbMetaTiles = new System.Windows.Forms.PictureBox();
            this.tabTiles = new System.Windows.Forms.TabPage();
            this.panelTiles = new System.Windows.Forms.Panel();
            this.pbTiles = new System.Windows.Forms.PictureBox();
            this.tabPalette = new System.Windows.Forms.TabPage();
            this.pbPalette = new System.Windows.Forms.PictureBox();
            this.tabRaw = new System.Windows.Forms.TabPage();
            this.udImageWidth = new System.Windows.Forms.NumericUpDown();
            this.btnDecodeRaw = new System.Windows.Forms.Button();
            this.numericUpDown1 = new System.Windows.Forms.NumericUpDown();
            this.pbRaw = new System.Windows.Forms.PictureBox();
            this.btnDecodeRun = new System.Windows.Forms.Button();
            this.btnText = new System.Windows.Forms.Button();
            this.tabPage1 = new System.Windows.Forms.TabPage();
            this.tbLog = new System.Windows.Forms.TextBox();
            this.nudStageIndex = new System.Windows.Forms.NumericUpDown();
            this.cbLevelType = new System.Windows.Forms.ComboBox();
            this.trackEditor = new MicroMachinesEditor.TrackEditor();
            this.statusStrip1.SuspendLayout();
            this.tabControl1.SuspendLayout();
            this.tabTrackList.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer1)).BeginInit();
            this.splitContainer1.Panel1.SuspendLayout();
            this.splitContainer1.Panel2.SuspendLayout();
            this.splitContainer1.SuspendLayout();
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
            ((System.ComponentModel.ISupportInitialize)(this.udImageWidth)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.numericUpDown1)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.pbRaw)).BeginInit();
            this.tabPage1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.nudStageIndex)).BeginInit();
            this.SuspendLayout();
            // 
            // tbFilename
            // 
            this.tbFilename.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.tbFilename.Location = new System.Drawing.Point(26, 25);
            this.tbFilename.Margin = new System.Windows.Forms.Padding(6);
            this.tbFilename.Name = "tbFilename";
            this.tbFilename.Size = new System.Drawing.Size(1522, 31);
            this.tbFilename.TabIndex = 0;
            this.tbFilename.Text = "C:\\Users\\Maxim\\Documents\\Roms\\Micro Machines.sms";
            // 
            // tbOffset
            // 
            this.tbOffset.Location = new System.Drawing.Point(12, 12);
            this.tbOffset.Margin = new System.Windows.Forms.Padding(6);
            this.tbOffset.Name = "tbOffset";
            this.tbOffset.Size = new System.Drawing.Size(96, 31);
            this.tbOffset.TabIndex = 0;
            this.tbOffset.Text = "2fde0";
            // 
            // tbOutput
            // 
            this.tbOutput.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.tbOutput.Font = new System.Drawing.Font("Consolas", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.tbOutput.Location = new System.Drawing.Point(12, 64);
            this.tbOutput.Margin = new System.Windows.Forms.Padding(6);
            this.tbOutput.Multiline = true;
            this.tbOutput.Name = "tbOutput";
            this.tbOutput.ReadOnly = true;
            this.tbOutput.ScrollBars = System.Windows.Forms.ScrollBars.Vertical;
            this.tbOutput.Size = new System.Drawing.Size(964, 436);
            this.tbOutput.TabIndex = 4;
            // 
            // btnDecode
            // 
            this.btnDecode.Location = new System.Drawing.Point(120, 8);
            this.btnDecode.Margin = new System.Windows.Forms.Padding(6);
            this.btnDecode.Name = "btnDecode";
            this.btnDecode.Size = new System.Drawing.Size(150, 44);
            this.btnDecode.TabIndex = 1;
            this.btnDecode.Text = "Decompress";
            this.btnDecode.UseVisualStyleBackColor = true;
            this.btnDecode.Click += new System.EventHandler(this.btnDecode_Click);
            // 
            // statusStrip1
            // 
            this.statusStrip1.ImageScalingSize = new System.Drawing.Size(32, 32);
            this.statusStrip1.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.toolStripStatusLabel1});
            this.statusStrip1.Location = new System.Drawing.Point(0, 688);
            this.statusStrip1.Name = "statusStrip1";
            this.statusStrip1.Padding = new System.Windows.Forms.Padding(2, 0, 28, 0);
            this.statusStrip1.Size = new System.Drawing.Size(1576, 37);
            this.statusStrip1.TabIndex = 5;
            this.statusStrip1.Text = "statusStrip1";
            // 
            // toolStripStatusLabel1
            // 
            this.toolStripStatusLabel1.Name = "toolStripStatusLabel1";
            this.toolStripStatusLabel1.Size = new System.Drawing.Size(79, 32);
            this.toolStripStatusLabel1.Text = "Ready";
            // 
            // btnSearch
            // 
            this.btnSearch.Location = new System.Drawing.Point(282, 7);
            this.btnSearch.Margin = new System.Windows.Forms.Padding(6);
            this.btnSearch.Name = "btnSearch";
            this.btnSearch.Size = new System.Drawing.Size(150, 44);
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
            this.tabControl1.Controls.Add(this.tabPage1);
            this.tabControl1.Location = new System.Drawing.Point(24, 127);
            this.tabControl1.Margin = new System.Windows.Forms.Padding(6);
            this.tabControl1.Name = "tabControl1";
            this.tabControl1.SelectedIndex = 0;
            this.tabControl1.Size = new System.Drawing.Size(1528, 550);
            this.tabControl1.TabIndex = 3;
            // 
            // tabTrackList
            // 
            this.tabTrackList.Controls.Add(this.splitContainer1);
            this.tabTrackList.Location = new System.Drawing.Point(8, 39);
            this.tabTrackList.Margin = new System.Windows.Forms.Padding(6);
            this.tabTrackList.Name = "tabTrackList";
            this.tabTrackList.Padding = new System.Windows.Forms.Padding(6);
            this.tabTrackList.Size = new System.Drawing.Size(1512, 503);
            this.tabTrackList.TabIndex = 9;
            this.tabTrackList.Text = "Track list";
            this.tabTrackList.UseVisualStyleBackColor = true;
            // 
            // splitContainer1
            // 
            this.splitContainer1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.splitContainer1.FixedPanel = System.Windows.Forms.FixedPanel.Panel2;
            this.splitContainer1.Location = new System.Drawing.Point(6, 6);
            this.splitContainer1.Name = "splitContainer1";
            // 
            // splitContainer1.Panel1
            // 
            this.splitContainer1.Panel1.Controls.Add(this.lvTracks);
            // 
            // splitContainer1.Panel2
            // 
            this.splitContainer1.Panel2.Controls.Add(this.pgTrack);
            this.splitContainer1.Panel2MinSize = 100;
            this.splitContainer1.Size = new System.Drawing.Size(1500, 491);
            this.splitContainer1.SplitterDistance = 1203;
            this.splitContainer1.TabIndex = 2;
            // 
            // lvTracks
            // 
            this.lvTracks.ContextMenuStrip = this.trackListMenu;
            this.lvTracks.Dock = System.Windows.Forms.DockStyle.Fill;
            this.lvTracks.HideSelection = false;
            this.lvTracks.Location = new System.Drawing.Point(0, 0);
            this.lvTracks.Margin = new System.Windows.Forms.Padding(6);
            this.lvTracks.MultiSelect = false;
            this.lvTracks.Name = "lvTracks";
            this.lvTracks.ShowGroups = false;
            this.lvTracks.Size = new System.Drawing.Size(1203, 491);
            this.lvTracks.TabIndex = 0;
            this.lvTracks.UseCompatibleStateImageBehavior = false;
            this.lvTracks.SelectedIndexChanged += new System.EventHandler(this.lvTracks_SelectedIndexChanged);
            // 
            // trackListMenu
            // 
            this.trackListMenu.ImageScalingSize = new System.Drawing.Size(32, 32);
            this.trackListMenu.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.editTrackToolStripMenuItem});
            this.trackListMenu.Name = "trackListMenu";
            this.trackListMenu.Size = new System.Drawing.Size(214, 42);
            // 
            // editTrackToolStripMenuItem
            // 
            this.editTrackToolStripMenuItem.Name = "editTrackToolStripMenuItem";
            this.editTrackToolStripMenuItem.Size = new System.Drawing.Size(213, 38);
            this.editTrackToolStripMenuItem.Text = "Edit track";
            this.editTrackToolStripMenuItem.Click += new System.EventHandler(this.editTrackToolStripMenuItem_Click);
            // 
            // pgTrack
            // 
            this.pgTrack.Dock = System.Windows.Forms.DockStyle.Fill;
            this.pgTrack.Location = new System.Drawing.Point(0, 0);
            this.pgTrack.Margin = new System.Windows.Forms.Padding(6);
            this.pgTrack.Name = "pgTrack";
            this.pgTrack.PropertySort = System.Windows.Forms.PropertySort.Alphabetical;
            this.pgTrack.Size = new System.Drawing.Size(293, 491);
            this.pgTrack.TabIndex = 1;
            this.pgTrack.ToolbarVisible = false;
            // 
            // tabTrack
            // 
            this.tabTrack.Controls.Add(this.trackEditor);
            this.tabTrack.Location = new System.Drawing.Point(8, 39);
            this.tabTrack.Margin = new System.Windows.Forms.Padding(6);
            this.tabTrack.Name = "tabTrack";
            this.tabTrack.Padding = new System.Windows.Forms.Padding(6);
            this.tabTrack.Size = new System.Drawing.Size(1512, 503);
            this.tabTrack.TabIndex = 4;
            this.tabTrack.Text = "Track";
            this.tabTrack.UseVisualStyleBackColor = true;
            // 
            // tabMetaTiles
            // 
            this.tabMetaTiles.Controls.Add(this.panelMetaTiles);
            this.tabMetaTiles.Location = new System.Drawing.Point(8, 39);
            this.tabMetaTiles.Margin = new System.Windows.Forms.Padding(6);
            this.tabMetaTiles.Name = "tabMetaTiles";
            this.tabMetaTiles.Padding = new System.Windows.Forms.Padding(6);
            this.tabMetaTiles.Size = new System.Drawing.Size(1512, 503);
            this.tabMetaTiles.TabIndex = 7;
            this.tabMetaTiles.Text = "Metatiles";
            this.tabMetaTiles.UseVisualStyleBackColor = true;
            // 
            // panelMetaTiles
            // 
            this.panelMetaTiles.AutoScroll = true;
            this.panelMetaTiles.Controls.Add(this.pbMetaTiles);
            this.panelMetaTiles.Dock = System.Windows.Forms.DockStyle.Fill;
            this.panelMetaTiles.Location = new System.Drawing.Point(6, 6);
            this.panelMetaTiles.Margin = new System.Windows.Forms.Padding(6);
            this.panelMetaTiles.Name = "panelMetaTiles";
            this.panelMetaTiles.Size = new System.Drawing.Size(1500, 491);
            this.panelMetaTiles.TabIndex = 4;
            // 
            // pbMetaTiles
            // 
            this.pbMetaTiles.Location = new System.Drawing.Point(0, 0);
            this.pbMetaTiles.Margin = new System.Windows.Forms.Padding(6);
            this.pbMetaTiles.Name = "pbMetaTiles";
            this.pbMetaTiles.Size = new System.Drawing.Size(96, 96);
            this.pbMetaTiles.SizeMode = System.Windows.Forms.PictureBoxSizeMode.AutoSize;
            this.pbMetaTiles.TabIndex = 3;
            this.pbMetaTiles.TabStop = false;
            // 
            // tabTiles
            // 
            this.tabTiles.Controls.Add(this.panelTiles);
            this.tabTiles.Location = new System.Drawing.Point(8, 39);
            this.tabTiles.Margin = new System.Windows.Forms.Padding(6);
            this.tabTiles.Name = "tabTiles";
            this.tabTiles.Padding = new System.Windows.Forms.Padding(6);
            this.tabTiles.Size = new System.Drawing.Size(1512, 503);
            this.tabTiles.TabIndex = 6;
            this.tabTiles.Text = "Tiles";
            this.tabTiles.UseVisualStyleBackColor = true;
            // 
            // panelTiles
            // 
            this.panelTiles.AutoScroll = true;
            this.panelTiles.Controls.Add(this.pbTiles);
            this.panelTiles.Dock = System.Windows.Forms.DockStyle.Fill;
            this.panelTiles.Location = new System.Drawing.Point(6, 6);
            this.panelTiles.Margin = new System.Windows.Forms.Padding(6);
            this.panelTiles.Name = "panelTiles";
            this.panelTiles.Size = new System.Drawing.Size(1500, 491);
            this.panelTiles.TabIndex = 3;
            // 
            // pbTiles
            // 
            this.pbTiles.Location = new System.Drawing.Point(0, 0);
            this.pbTiles.Margin = new System.Windows.Forms.Padding(6);
            this.pbTiles.Name = "pbTiles";
            this.pbTiles.Size = new System.Drawing.Size(768, 768);
            this.pbTiles.SizeMode = System.Windows.Forms.PictureBoxSizeMode.AutoSize;
            this.pbTiles.TabIndex = 2;
            this.pbTiles.TabStop = false;
            // 
            // tabPalette
            // 
            this.tabPalette.Controls.Add(this.pbPalette);
            this.tabPalette.Location = new System.Drawing.Point(8, 39);
            this.tabPalette.Margin = new System.Windows.Forms.Padding(6);
            this.tabPalette.Name = "tabPalette";
            this.tabPalette.Padding = new System.Windows.Forms.Padding(6);
            this.tabPalette.Size = new System.Drawing.Size(1512, 503);
            this.tabPalette.TabIndex = 5;
            this.tabPalette.Text = "Palette";
            this.tabPalette.UseVisualStyleBackColor = true;
            // 
            // pbPalette
            // 
            this.pbPalette.Dock = System.Windows.Forms.DockStyle.Top;
            this.pbPalette.Location = new System.Drawing.Point(6, 6);
            this.pbPalette.Margin = new System.Windows.Forms.Padding(6);
            this.pbPalette.Name = "pbPalette";
            this.pbPalette.Size = new System.Drawing.Size(1500, 96);
            this.pbPalette.SizeMode = System.Windows.Forms.PictureBoxSizeMode.StretchImage;
            this.pbPalette.TabIndex = 0;
            this.pbPalette.TabStop = false;
            this.pbPalette.Paint += new System.Windows.Forms.PaintEventHandler(this.pbPalette_Paint);
            // 
            // tabRaw
            // 
            this.tabRaw.Controls.Add(this.udImageWidth);
            this.tabRaw.Controls.Add(this.btnDecodeRaw);
            this.tabRaw.Controls.Add(this.numericUpDown1);
            this.tabRaw.Controls.Add(this.pbRaw);
            this.tabRaw.Controls.Add(this.btnDecodeRun);
            this.tabRaw.Controls.Add(this.btnText);
            this.tabRaw.Controls.Add(this.tbOffset);
            this.tabRaw.Controls.Add(this.btnSearch);
            this.tabRaw.Controls.Add(this.tbOutput);
            this.tabRaw.Controls.Add(this.btnDecode);
            this.tabRaw.Location = new System.Drawing.Point(8, 39);
            this.tabRaw.Margin = new System.Windows.Forms.Padding(6);
            this.tabRaw.Name = "tabRaw";
            this.tabRaw.Padding = new System.Windows.Forms.Padding(6);
            this.tabRaw.Size = new System.Drawing.Size(1512, 503);
            this.tabRaw.TabIndex = 0;
            this.tabRaw.Text = "Raw";
            this.tabRaw.UseVisualStyleBackColor = true;
            // 
            // udImageWidth
            // 
            this.udImageWidth.Increment = new decimal(new int[] {
            8,
            0,
            0,
            0});
            this.udImageWidth.Location = new System.Drawing.Point(1161, 13);
            this.udImageWidth.Maximum = new decimal(new int[] {
            256,
            0,
            0,
            0});
            this.udImageWidth.Minimum = new decimal(new int[] {
            8,
            0,
            0,
            0});
            this.udImageWidth.Name = "udImageWidth";
            this.udImageWidth.Size = new System.Drawing.Size(82, 31);
            this.udImageWidth.TabIndex = 10;
            this.udImageWidth.Value = new decimal(new int[] {
            32,
            0,
            0,
            0});
            // 
            // btnDecodeRaw
            // 
            this.btnDecodeRaw.Location = new System.Drawing.Point(777, 7);
            this.btnDecodeRaw.Margin = new System.Windows.Forms.Padding(6);
            this.btnDecodeRaw.Name = "btnDecodeRaw";
            this.btnDecodeRaw.Size = new System.Drawing.Size(159, 44);
            this.btnDecodeRaw.TabIndex = 9;
            this.btnDecodeRaw.Text = "Raw";
            this.btnDecodeRaw.UseVisualStyleBackColor = true;
            this.btnDecodeRaw.Click += new System.EventHandler(this.btnDecodeRaw_Click);
            // 
            // numericUpDown1
            // 
            this.numericUpDown1.Location = new System.Drawing.Point(1086, 16);
            this.numericUpDown1.Maximum = new decimal(new int[] {
            4,
            0,
            0,
            0});
            this.numericUpDown1.Minimum = new decimal(new int[] {
            1,
            0,
            0,
            0});
            this.numericUpDown1.Name = "numericUpDown1";
            this.numericUpDown1.Size = new System.Drawing.Size(69, 31);
            this.numericUpDown1.TabIndex = 8;
            this.numericUpDown1.Value = new decimal(new int[] {
            3,
            0,
            0,
            0});
            // 
            // pbRaw
            // 
            this.pbRaw.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.pbRaw.Location = new System.Drawing.Point(988, 56);
            this.pbRaw.Margin = new System.Windows.Forms.Padding(6);
            this.pbRaw.Name = "pbRaw";
            this.pbRaw.Size = new System.Drawing.Size(512, 512);
            this.pbRaw.SizeMode = System.Windows.Forms.PictureBoxSizeMode.AutoSize;
            this.pbRaw.TabIndex = 7;
            this.pbRaw.TabStop = false;
            // 
            // btnDecodeRun
            // 
            this.btnDecodeRun.Location = new System.Drawing.Point(606, 7);
            this.btnDecodeRun.Margin = new System.Windows.Forms.Padding(6);
            this.btnDecodeRun.Name = "btnDecodeRun";
            this.btnDecodeRun.Size = new System.Drawing.Size(159, 44);
            this.btnDecodeRun.TabIndex = 5;
            this.btnDecodeRun.Text = "Decode RLE";
            this.btnDecodeRun.UseVisualStyleBackColor = true;
            this.btnDecodeRun.Click += new System.EventHandler(this.btnDecodeRun_Click);
            // 
            // btnText
            // 
            this.btnText.Location = new System.Drawing.Point(444, 8);
            this.btnText.Margin = new System.Windows.Forms.Padding(6);
            this.btnText.Name = "btnText";
            this.btnText.Size = new System.Drawing.Size(150, 44);
            this.btnText.TabIndex = 3;
            this.btnText.Text = "Text";
            this.btnText.UseVisualStyleBackColor = true;
            this.btnText.Click += new System.EventHandler(this.btnText_Click);
            // 
            // tabPage1
            // 
            this.tabPage1.Controls.Add(this.tbLog);
            this.tabPage1.Location = new System.Drawing.Point(8, 39);
            this.tabPage1.Name = "tabPage1";
            this.tabPage1.Padding = new System.Windows.Forms.Padding(3);
            this.tabPage1.Size = new System.Drawing.Size(1512, 503);
            this.tabPage1.TabIndex = 10;
            this.tabPage1.Text = "Log";
            this.tabPage1.UseVisualStyleBackColor = true;
            // 
            // tbLog
            // 
            this.tbLog.Dock = System.Windows.Forms.DockStyle.Fill;
            this.tbLog.Font = new System.Drawing.Font("Consolas", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.tbLog.Location = new System.Drawing.Point(3, 3);
            this.tbLog.Margin = new System.Windows.Forms.Padding(6);
            this.tbLog.Multiline = true;
            this.tbLog.Name = "tbLog";
            this.tbLog.ReadOnly = true;
            this.tbLog.ScrollBars = System.Windows.Forms.ScrollBars.Vertical;
            this.tbLog.Size = new System.Drawing.Size(1506, 497);
            this.tbLog.TabIndex = 1;
            // 
            // nudStageIndex
            // 
            this.nudStageIndex.Location = new System.Drawing.Point(278, 75);
            this.nudStageIndex.Margin = new System.Windows.Forms.Padding(6);
            this.nudStageIndex.Maximum = new decimal(new int[] {
            3,
            0,
            0,
            0});
            this.nudStageIndex.Name = "nudStageIndex";
            this.nudStageIndex.Size = new System.Drawing.Size(96, 31);
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
            this.cbLevelType.Location = new System.Drawing.Point(24, 75);
            this.cbLevelType.Margin = new System.Windows.Forms.Padding(6);
            this.cbLevelType.Name = "cbLevelType";
            this.cbLevelType.Size = new System.Drawing.Size(238, 33);
            this.cbLevelType.TabIndex = 1;
            this.cbLevelType.SelectedIndexChanged += new System.EventHandler(this.TrackParametersChanged);
            // 
            // trackEditor
            // 
            this.trackEditor.Dock = System.Windows.Forms.DockStyle.Fill;
            this.trackEditor.Location = new System.Drawing.Point(6, 6);
            this.trackEditor.Margin = new System.Windows.Forms.Padding(12);
            this.trackEditor.Name = "trackEditor";
            this.trackEditor.Size = new System.Drawing.Size(1500, 491);
            this.trackEditor.TabIndex = 0;
            this.trackEditor.Track = null;
            // 
            // MainForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(12F, 25F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(1576, 725);
            this.Controls.Add(this.tabControl1);
            this.Controls.Add(this.nudStageIndex);
            this.Controls.Add(this.statusStrip1);
            this.Controls.Add(this.cbLevelType);
            this.Controls.Add(this.tbFilename);
            this.Margin = new System.Windows.Forms.Padding(6);
            this.Name = "MainForm";
            this.Text = "Micro Machines Editor";
            this.Load += new System.EventHandler(this.Form1_Load);
            this.statusStrip1.ResumeLayout(false);
            this.statusStrip1.PerformLayout();
            this.tabControl1.ResumeLayout(false);
            this.tabTrackList.ResumeLayout(false);
            this.splitContainer1.Panel1.ResumeLayout(false);
            this.splitContainer1.Panel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer1)).EndInit();
            this.splitContainer1.ResumeLayout(false);
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
            ((System.ComponentModel.ISupportInitialize)(this.udImageWidth)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.numericUpDown1)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.pbRaw)).EndInit();
            this.tabPage1.ResumeLayout(false);
            this.tabPage1.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.nudStageIndex)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.TextBox tbFilename;
        private System.Windows.Forms.TextBox tbOffset;
        private System.Windows.Forms.TextBox tbOutput;
        private System.Windows.Forms.Button btnDecode;
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
        private System.Windows.Forms.ContextMenuStrip trackListMenu;
        private System.Windows.Forms.ToolStripMenuItem editTrackToolStripMenuItem;
        private TrackEditor trackEditor;
        private System.Windows.Forms.SplitContainer splitContainer1;
        private System.Windows.Forms.TabPage tabPage1;
        private System.Windows.Forms.TextBox tbLog;
        private System.Windows.Forms.PropertyGrid pgTrack;
        private System.Windows.Forms.Button btnDecodeRun;
        private System.Windows.Forms.PictureBox pbRaw;
        private System.Windows.Forms.NumericUpDown numericUpDown1;
        private System.Windows.Forms.Button btnDecodeRaw;
        private System.Windows.Forms.NumericUpDown udImageWidth;
    }
}

