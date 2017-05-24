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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(MainForm));
            this.statusStrip1 = new System.Windows.Forms.StatusStrip();
            this.toolStripStatusLabel1 = new System.Windows.Forms.ToolStripStatusLabel();
            this.tabControl1 = new System.Windows.Forms.TabControl();
            this.tabTrackList = new System.Windows.Forms.TabPage();
            this.splitContainer1 = new System.Windows.Forms.SplitContainer();
            this.lvTracks = new System.Windows.Forms.ListView();
            this.trackListMenu = new System.Windows.Forms.ContextMenuStrip(this.components);
            this.editTrackToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.pgTrack = new System.Windows.Forms.PropertyGrid();
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
            this.splitContainer2 = new System.Windows.Forms.SplitContainer();
            this.tbOutput = new System.Windows.Forms.TextBox();
            this.pbRaw = new System.Windows.Forms.PictureBox();
            this.flowLayoutPanel1 = new System.Windows.Forms.FlowLayoutPanel();
            this.numericUpDown1 = new System.Windows.Forms.NumericUpDown();
            this.udImageWidth = new System.Windows.Forms.NumericUpDown();
            this.cbPalette = new System.Windows.Forms.ComboBox();
            this.udSkip = new System.Windows.Forms.NumericUpDown();
            this.toolStrip1 = new System.Windows.Forms.ToolStrip();
            this.toolStripLabel1 = new System.Windows.Forms.ToolStripLabel();
            this.tbOffset = new System.Windows.Forms.ToolStripTextBox();
            this.toolStripSeparator2 = new System.Windows.Forms.ToolStripSeparator();
            this.toolStripLabel2 = new System.Windows.Forms.ToolStripLabel();
            this.btnDecode = new System.Windows.Forms.ToolStripButton();
            this.btnSearch = new System.Windows.Forms.ToolStripButton();
            this.btnText = new System.Windows.Forms.ToolStripButton();
            this.btnDecodeRun = new System.Windows.Forms.ToolStripButton();
            this.btnDecodeRaw = new System.Windows.Forms.ToolStripButton();
            this.toolStripSeparator1 = new System.Windows.Forms.ToolStripSeparator();
            this.btnDecompressRun = new System.Windows.Forms.ToolStripButton();
            this.tbRunBytes = new System.Windows.Forms.ToolStripTextBox();
            this.toolStripSeparator3 = new System.Windows.Forms.ToolStripSeparator();
            this.toolStripDropDownButton1 = new System.Windows.Forms.ToolStripDropDownButton();
            this.exhaustiveToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.fastToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.tabPage1 = new System.Windows.Forms.TabPage();
            this.tbLog = new System.Windows.Forms.TextBox();
            this.nudStageIndex = new System.Windows.Forms.NumericUpDown();
            this.cbLevelType = new System.Windows.Forms.ComboBox();
            this.tbFilename = new System.Windows.Forms.TextBox();
            this.panel1 = new System.Windows.Forms.Panel();
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
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer2)).BeginInit();
            this.splitContainer2.Panel1.SuspendLayout();
            this.splitContainer2.Panel2.SuspendLayout();
            this.splitContainer2.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.pbRaw)).BeginInit();
            this.flowLayoutPanel1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.numericUpDown1)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.udImageWidth)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.udSkip)).BeginInit();
            this.toolStrip1.SuspendLayout();
            this.tabPage1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.nudStageIndex)).BeginInit();
            this.panel1.SuspendLayout();
            this.SuspendLayout();
            // 
            // statusStrip1
            // 
            this.statusStrip1.ImageScalingSize = new System.Drawing.Size(32, 32);
            this.statusStrip1.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.toolStripStatusLabel1});
            this.statusStrip1.Location = new System.Drawing.Point(0, 688);
            this.statusStrip1.Name = "statusStrip1";
            this.statusStrip1.Padding = new System.Windows.Forms.Padding(2, 0, 28, 0);
            this.statusStrip1.Size = new System.Drawing.Size(1730, 37);
            this.statusStrip1.TabIndex = 5;
            this.statusStrip1.Text = "statusStrip1";
            // 
            // toolStripStatusLabel1
            // 
            this.toolStripStatusLabel1.Name = "toolStripStatusLabel1";
            this.toolStripStatusLabel1.Size = new System.Drawing.Size(79, 32);
            this.toolStripStatusLabel1.Text = "Ready";
            // 
            // tabControl1
            // 
            this.tabControl1.Controls.Add(this.tabTrackList);
            this.tabControl1.Controls.Add(this.tabTrack);
            this.tabControl1.Controls.Add(this.tabMetaTiles);
            this.tabControl1.Controls.Add(this.tabTiles);
            this.tabControl1.Controls.Add(this.tabPalette);
            this.tabControl1.Controls.Add(this.tabRaw);
            this.tabControl1.Controls.Add(this.tabPage1);
            this.tabControl1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.tabControl1.Location = new System.Drawing.Point(0, 100);
            this.tabControl1.Margin = new System.Windows.Forms.Padding(6);
            this.tabControl1.Name = "tabControl1";
            this.tabControl1.SelectedIndex = 0;
            this.tabControl1.Size = new System.Drawing.Size(1730, 588);
            this.tabControl1.TabIndex = 0;
            // 
            // tabTrackList
            // 
            this.tabTrackList.Controls.Add(this.splitContainer1);
            this.tabTrackList.Location = new System.Drawing.Point(8, 39);
            this.tabTrackList.Margin = new System.Windows.Forms.Padding(6);
            this.tabTrackList.Name = "tabTrackList";
            this.tabTrackList.Padding = new System.Windows.Forms.Padding(6);
            this.tabTrackList.Size = new System.Drawing.Size(1714, 541);
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
            this.splitContainer1.Size = new System.Drawing.Size(1702, 529);
            this.splitContainer1.SplitterDistance = 1405;
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
            this.lvTracks.Size = new System.Drawing.Size(1405, 529);
            this.lvTracks.TabIndex = 0;
            this.lvTracks.UseCompatibleStateImageBehavior = false;
            this.lvTracks.SelectedIndexChanged += new System.EventHandler(this.lvTracks_SelectedIndexChanged);
            this.lvTracks.MouseDoubleClick += new System.Windows.Forms.MouseEventHandler(this.lvTracks_MouseDoubleClick);
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
            this.pgTrack.Size = new System.Drawing.Size(293, 529);
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
            this.tabTrack.Size = new System.Drawing.Size(1714, 541);
            this.tabTrack.TabIndex = 4;
            this.tabTrack.Text = "Track";
            this.tabTrack.UseVisualStyleBackColor = true;
            // 
            // trackEditor
            // 
            this.trackEditor.Dock = System.Windows.Forms.DockStyle.Fill;
            this.trackEditor.Location = new System.Drawing.Point(6, 6);
            this.trackEditor.Margin = new System.Windows.Forms.Padding(12);
            this.trackEditor.Name = "trackEditor";
            this.trackEditor.Size = new System.Drawing.Size(1702, 529);
            this.trackEditor.TabIndex = 0;
            this.trackEditor.Track = null;
            // 
            // tabMetaTiles
            // 
            this.tabMetaTiles.Controls.Add(this.panelMetaTiles);
            this.tabMetaTiles.Location = new System.Drawing.Point(8, 39);
            this.tabMetaTiles.Margin = new System.Windows.Forms.Padding(6);
            this.tabMetaTiles.Name = "tabMetaTiles";
            this.tabMetaTiles.Padding = new System.Windows.Forms.Padding(6);
            this.tabMetaTiles.Size = new System.Drawing.Size(1714, 541);
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
            this.panelMetaTiles.Size = new System.Drawing.Size(1702, 529);
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
            this.tabTiles.Size = new System.Drawing.Size(1714, 541);
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
            this.panelTiles.Size = new System.Drawing.Size(1702, 529);
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
            this.tabPalette.Size = new System.Drawing.Size(1714, 541);
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
            this.pbPalette.Size = new System.Drawing.Size(1702, 96);
            this.pbPalette.SizeMode = System.Windows.Forms.PictureBoxSizeMode.StretchImage;
            this.pbPalette.TabIndex = 0;
            this.pbPalette.TabStop = false;
            this.pbPalette.Paint += new System.Windows.Forms.PaintEventHandler(this.pbPalette_Paint);
            // 
            // tabRaw
            // 
            this.tabRaw.Controls.Add(this.splitContainer2);
            this.tabRaw.Controls.Add(this.toolStrip1);
            this.tabRaw.Location = new System.Drawing.Point(8, 39);
            this.tabRaw.Margin = new System.Windows.Forms.Padding(6);
            this.tabRaw.Name = "tabRaw";
            this.tabRaw.Padding = new System.Windows.Forms.Padding(6);
            this.tabRaw.Size = new System.Drawing.Size(1714, 541);
            this.tabRaw.TabIndex = 0;
            this.tabRaw.Text = "Raw";
            this.tabRaw.UseVisualStyleBackColor = true;
            // 
            // splitContainer2
            // 
            this.splitContainer2.Dock = System.Windows.Forms.DockStyle.Fill;
            this.splitContainer2.Location = new System.Drawing.Point(6, 45);
            this.splitContainer2.Name = "splitContainer2";
            // 
            // splitContainer2.Panel1
            // 
            this.splitContainer2.Panel1.Controls.Add(this.tbOutput);
            // 
            // splitContainer2.Panel2
            // 
            this.splitContainer2.Panel2.Controls.Add(this.pbRaw);
            this.splitContainer2.Panel2.Controls.Add(this.flowLayoutPanel1);
            this.splitContainer2.Size = new System.Drawing.Size(1702, 490);
            this.splitContainer2.SplitterDistance = 537;
            this.splitContainer2.TabIndex = 14;
            // 
            // tbOutput
            // 
            this.tbOutput.Dock = System.Windows.Forms.DockStyle.Fill;
            this.tbOutput.Font = new System.Drawing.Font("Consolas", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.tbOutput.Location = new System.Drawing.Point(0, 0);
            this.tbOutput.Margin = new System.Windows.Forms.Padding(6);
            this.tbOutput.Multiline = true;
            this.tbOutput.Name = "tbOutput";
            this.tbOutput.ReadOnly = true;
            this.tbOutput.ScrollBars = System.Windows.Forms.ScrollBars.Vertical;
            this.tbOutput.Size = new System.Drawing.Size(537, 490);
            this.tbOutput.TabIndex = 10;
            // 
            // pbRaw
            // 
            this.pbRaw.Dock = System.Windows.Forms.DockStyle.Fill;
            this.pbRaw.Location = new System.Drawing.Point(0, 39);
            this.pbRaw.Margin = new System.Windows.Forms.Padding(6);
            this.pbRaw.Name = "pbRaw";
            this.pbRaw.Size = new System.Drawing.Size(1161, 451);
            this.pbRaw.TabIndex = 8;
            this.pbRaw.TabStop = false;
            // 
            // flowLayoutPanel1
            // 
            this.flowLayoutPanel1.AutoSize = true;
            this.flowLayoutPanel1.AutoSizeMode = System.Windows.Forms.AutoSizeMode.GrowAndShrink;
            this.flowLayoutPanel1.Controls.Add(this.numericUpDown1);
            this.flowLayoutPanel1.Controls.Add(this.udImageWidth);
            this.flowLayoutPanel1.Controls.Add(this.cbPalette);
            this.flowLayoutPanel1.Controls.Add(this.udSkip);
            this.flowLayoutPanel1.Dock = System.Windows.Forms.DockStyle.Top;
            this.flowLayoutPanel1.Location = new System.Drawing.Point(0, 0);
            this.flowLayoutPanel1.Name = "flowLayoutPanel1";
            this.flowLayoutPanel1.Size = new System.Drawing.Size(1161, 39);
            this.flowLayoutPanel1.TabIndex = 9;
            // 
            // numericUpDown1
            // 
            this.numericUpDown1.Location = new System.Drawing.Point(3, 3);
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
            this.numericUpDown1.TabIndex = 6;
            this.numericUpDown1.Value = new decimal(new int[] {
            3,
            0,
            0,
            0});
            this.numericUpDown1.ValueChanged += new System.EventHandler(this.numericUpDown1_ValueChanged);
            // 
            // udImageWidth
            // 
            this.udImageWidth.Increment = new decimal(new int[] {
            8,
            0,
            0,
            0});
            this.udImageWidth.Location = new System.Drawing.Point(78, 3);
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
            this.udImageWidth.TabIndex = 7;
            this.udImageWidth.Value = new decimal(new int[] {
            32,
            0,
            0,
            0});
            this.udImageWidth.ValueChanged += new System.EventHandler(this.numericUpDown1_ValueChanged);
            // 
            // cbPalette
            // 
            this.cbPalette.FormattingEnabled = true;
            this.cbPalette.Items.AddRange(new object[] {
            "BF3E Menu",
            "BF80 Menu (GG)",
            "17ED2 Sportscars tiles",
            "17EE2 Sportscars sprites",
            "17EF2 Four by Four tiles",
            "17F02 Four by Four sprites",
            "17F12 Powerboats tiles",
            "17F22 Powerboats sprites",
            "17F32 Turbo Wheels tiles",
            "17F42 Turbo Wheels sprites",
            "17F52 Formula One tiles",
            "17F62 Formula One sprites",
            "17F72 Warriors tiles",
            "17F82 Warriors sprites",
            "17F92 Tanks tiles",
            "17FA2 Tanks sprites",
            "17FB2 RuffTrux tiles",
            "17FC2 RuffTrux sprites"});
            this.cbPalette.Location = new System.Drawing.Point(166, 3);
            this.cbPalette.Name = "cbPalette";
            this.cbPalette.Size = new System.Drawing.Size(259, 33);
            this.cbPalette.TabIndex = 8;
            this.cbPalette.SelectedIndexChanged += new System.EventHandler(this.numericUpDown1_ValueChanged);
            // 
            // udSkip
            // 
            this.udSkip.Location = new System.Drawing.Point(431, 3);
            this.udSkip.Maximum = new decimal(new int[] {
            256,
            0,
            0,
            0});
            this.udSkip.Name = "udSkip";
            this.udSkip.Size = new System.Drawing.Size(82, 31);
            this.udSkip.TabIndex = 10;
            this.udSkip.ValueChanged += new System.EventHandler(this.numericUpDown1_ValueChanged);
            // 
            // toolStrip1
            // 
            this.toolStrip1.ImageScalingSize = new System.Drawing.Size(32, 32);
            this.toolStrip1.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.toolStripLabel1,
            this.tbOffset,
            this.toolStripSeparator2,
            this.toolStripLabel2,
            this.btnDecode,
            this.btnSearch,
            this.btnText,
            this.btnDecodeRun,
            this.btnDecodeRaw,
            this.toolStripSeparator1,
            this.btnDecompressRun,
            this.tbRunBytes,
            this.toolStripSeparator3,
            this.toolStripDropDownButton1});
            this.toolStrip1.Location = new System.Drawing.Point(6, 6);
            this.toolStrip1.Name = "toolStrip1";
            this.toolStrip1.Size = new System.Drawing.Size(1702, 39);
            this.toolStrip1.TabIndex = 13;
            this.toolStrip1.Text = "toolStrip1";
            // 
            // toolStripLabel1
            // 
            this.toolStripLabel1.Name = "toolStripLabel1";
            this.toolStripLabel1.Size = new System.Drawing.Size(80, 36);
            this.toolStripLabel1.Text = "Offset";
            // 
            // tbOffset
            // 
            this.tbOffset.Name = "tbOffset";
            this.tbOffset.Size = new System.Drawing.Size(100, 39);
            this.tbOffset.Text = "2fde0";
            // 
            // toolStripSeparator2
            // 
            this.toolStripSeparator2.Name = "toolStripSeparator2";
            this.toolStripSeparator2.Size = new System.Drawing.Size(6, 39);
            // 
            // toolStripLabel2
            // 
            this.toolStripLabel2.Name = "toolStripLabel2";
            this.toolStripLabel2.Size = new System.Drawing.Size(97, 36);
            this.toolStripLabel2.Text = "Decode";
            // 
            // btnDecode
            // 
            this.btnDecode.Image = ((System.Drawing.Image)(resources.GetObject("btnDecode.Image")));
            this.btnDecode.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.btnDecode.Name = "btnDecode";
            this.btnDecode.Size = new System.Drawing.Size(93, 36);
            this.btnDecode.Text = "LZ+";
            this.btnDecode.Click += new System.EventHandler(this.btnDecode_Click);
            // 
            // btnSearch
            // 
            this.btnSearch.Image = ((System.Drawing.Image)(resources.GetObject("btnSearch.Image")));
            this.btnSearch.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.btnSearch.Name = "btnSearch";
            this.btnSearch.Size = new System.Drawing.Size(122, 36);
            this.btnSearch.Text = "Search";
            this.btnSearch.Click += new System.EventHandler(this.btnSearch_Click);
            // 
            // btnText
            // 
            this.btnText.Image = ((System.Drawing.Image)(resources.GetObject("btnText.Image")));
            this.btnText.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.btnText.Name = "btnText";
            this.btnText.Size = new System.Drawing.Size(94, 36);
            this.btnText.Text = "Text";
            this.btnText.Click += new System.EventHandler(this.btnText_Click);
            // 
            // btnDecodeRun
            // 
            this.btnDecodeRun.Image = ((System.Drawing.Image)(resources.GetObject("btnDecodeRun.Image")));
            this.btnDecodeRun.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.btnDecodeRun.Name = "btnDecodeRun";
            this.btnDecodeRun.Size = new System.Drawing.Size(88, 36);
            this.btnDecodeRun.Text = "RLE";
            this.btnDecodeRun.Click += new System.EventHandler(this.btnDecodeRun_Click);
            // 
            // btnDecodeRaw
            // 
            this.btnDecodeRaw.Image = ((System.Drawing.Image)(resources.GetObject("btnDecodeRaw.Image")));
            this.btnDecodeRaw.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.btnDecodeRaw.Name = "btnDecodeRaw";
            this.btnDecodeRaw.Size = new System.Drawing.Size(94, 36);
            this.btnDecodeRaw.Text = "Raw";
            this.btnDecodeRaw.Click += new System.EventHandler(this.btnDecodeRaw_Click);
            // 
            // toolStripSeparator1
            // 
            this.toolStripSeparator1.Name = "toolStripSeparator1";
            this.toolStripSeparator1.Size = new System.Drawing.Size(6, 39);
            // 
            // btnDecompressRun
            // 
            this.btnDecompressRun.Image = ((System.Drawing.Image)(resources.GetObject("btnDecompressRun.Image")));
            this.btnDecompressRun.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.btnDecompressRun.Name = "btnDecompressRun";
            this.btnDecompressRun.Size = new System.Drawing.Size(93, 36);
            this.btnDecompressRun.Text = "Run";
            this.btnDecompressRun.Click += new System.EventHandler(this.btnDecompressRun_Click);
            // 
            // tbRunBytes
            // 
            this.tbRunBytes.Name = "tbRunBytes";
            this.tbRunBytes.Size = new System.Drawing.Size(100, 39);
            this.tbRunBytes.Text = "150";
            // 
            // toolStripSeparator3
            // 
            this.toolStripSeparator3.Name = "toolStripSeparator3";
            this.toolStripSeparator3.Size = new System.Drawing.Size(6, 39);
            // 
            // toolStripDropDownButton1
            // 
            this.toolStripDropDownButton1.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.exhaustiveToolStripMenuItem,
            this.fastToolStripMenuItem});
            this.toolStripDropDownButton1.Image = ((System.Drawing.Image)(resources.GetObject("toolStripDropDownButton1.Image")));
            this.toolStripDropDownButton1.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.toolStripDropDownButton1.Name = "toolStripDropDownButton1";
            this.toolStripDropDownButton1.Size = new System.Drawing.Size(189, 36);
            this.toolStripDropDownButton1.Text = "Compress...";
            // 
            // exhaustiveToolStripMenuItem
            // 
            this.exhaustiveToolStripMenuItem.Name = "exhaustiveToolStripMenuItem";
            this.exhaustiveToolStripMenuItem.Size = new System.Drawing.Size(227, 38);
            this.exhaustiveToolStripMenuItem.Text = "Exhaustive";
            this.exhaustiveToolStripMenuItem.Click += new System.EventHandler(this.exhaustiveToolStripMenuItem_Click);
            // 
            // fastToolStripMenuItem
            // 
            this.fastToolStripMenuItem.Name = "fastToolStripMenuItem";
            this.fastToolStripMenuItem.Size = new System.Drawing.Size(227, 38);
            this.fastToolStripMenuItem.Text = "Fast";
            this.fastToolStripMenuItem.Click += new System.EventHandler(this.fastToolStripMenuItem_Click);
            // 
            // tabPage1
            // 
            this.tabPage1.Controls.Add(this.tbLog);
            this.tabPage1.Location = new System.Drawing.Point(8, 39);
            this.tabPage1.Name = "tabPage1";
            this.tabPage1.Padding = new System.Windows.Forms.Padding(3);
            this.tabPage1.Size = new System.Drawing.Size(1714, 541);
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
            this.tbLog.Size = new System.Drawing.Size(1708, 535);
            this.tbLog.TabIndex = 1;
            // 
            // nudStageIndex
            // 
            this.nudStageIndex.Location = new System.Drawing.Point(265, 58);
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
            this.cbLevelType.Location = new System.Drawing.Point(15, 58);
            this.cbLevelType.Margin = new System.Windows.Forms.Padding(6);
            this.cbLevelType.Name = "cbLevelType";
            this.cbLevelType.Size = new System.Drawing.Size(238, 33);
            this.cbLevelType.TabIndex = 1;
            this.cbLevelType.SelectedIndexChanged += new System.EventHandler(this.TrackParametersChanged);
            // 
            // tbFilename
            // 
            this.tbFilename.Location = new System.Drawing.Point(15, 15);
            this.tbFilename.Name = "tbFilename";
            this.tbFilename.Size = new System.Drawing.Size(1676, 31);
            this.tbFilename.TabIndex = 0;
            // 
            // panel1
            // 
            this.panel1.Controls.Add(this.tbFilename);
            this.panel1.Controls.Add(this.cbLevelType);
            this.panel1.Controls.Add(this.nudStageIndex);
            this.panel1.Dock = System.Windows.Forms.DockStyle.Top;
            this.panel1.Location = new System.Drawing.Point(0, 0);
            this.panel1.Name = "panel1";
            this.panel1.Size = new System.Drawing.Size(1730, 100);
            this.panel1.TabIndex = 6;
            // 
            // MainForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(12F, 25F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(1730, 725);
            this.Controls.Add(this.tabControl1);
            this.Controls.Add(this.statusStrip1);
            this.Controls.Add(this.panel1);
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
            this.splitContainer2.Panel1.ResumeLayout(false);
            this.splitContainer2.Panel1.PerformLayout();
            this.splitContainer2.Panel2.ResumeLayout(false);
            this.splitContainer2.Panel2.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer2)).EndInit();
            this.splitContainer2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.pbRaw)).EndInit();
            this.flowLayoutPanel1.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.numericUpDown1)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.udImageWidth)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.udSkip)).EndInit();
            this.toolStrip1.ResumeLayout(false);
            this.toolStrip1.PerformLayout();
            this.tabPage1.ResumeLayout(false);
            this.tabPage1.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.nudStageIndex)).EndInit();
            this.panel1.ResumeLayout(false);
            this.panel1.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion
        private System.Windows.Forms.StatusStrip statusStrip1;
        private System.Windows.Forms.ToolStripStatusLabel toolStripStatusLabel1;
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
        private System.Windows.Forms.TabPage tabTrackList;
        private System.Windows.Forms.ListView lvTracks;
        private System.Windows.Forms.ContextMenuStrip trackListMenu;
        private System.Windows.Forms.ToolStripMenuItem editTrackToolStripMenuItem;
        private TrackEditor trackEditor;
        private System.Windows.Forms.SplitContainer splitContainer1;
        private System.Windows.Forms.TabPage tabPage1;
        private System.Windows.Forms.TextBox tbLog;
        private System.Windows.Forms.PropertyGrid pgTrack;
        private System.Windows.Forms.NumericUpDown numericUpDown1;
        private System.Windows.Forms.NumericUpDown udImageWidth;
        private System.Windows.Forms.ComboBox cbPalette;
        private System.Windows.Forms.NumericUpDown udSkip;
        private System.Windows.Forms.SplitContainer splitContainer2;
        private System.Windows.Forms.TextBox tbOutput;
        private System.Windows.Forms.PictureBox pbRaw;
        private System.Windows.Forms.FlowLayoutPanel flowLayoutPanel1;
        private System.Windows.Forms.ToolStrip toolStrip1;
        private System.Windows.Forms.ToolStripLabel toolStripLabel1;
        private System.Windows.Forms.ToolStripTextBox tbOffset;
        private System.Windows.Forms.ToolStripSeparator toolStripSeparator2;
        private System.Windows.Forms.ToolStripLabel toolStripLabel2;
        private System.Windows.Forms.ToolStripButton btnDecode;
        private System.Windows.Forms.ToolStripButton btnSearch;
        private System.Windows.Forms.ToolStripButton btnText;
        private System.Windows.Forms.ToolStripButton btnDecodeRun;
        private System.Windows.Forms.ToolStripButton btnDecodeRaw;
        private System.Windows.Forms.ToolStripSeparator toolStripSeparator1;
        private System.Windows.Forms.ToolStripButton btnDecompressRun;
        private System.Windows.Forms.ToolStripTextBox tbRunBytes;
        private System.Windows.Forms.ToolStripSeparator toolStripSeparator3;
        private System.Windows.Forms.ToolStripDropDownButton toolStripDropDownButton1;
        private System.Windows.Forms.ToolStripMenuItem exhaustiveToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem fastToolStripMenuItem;
        private System.Windows.Forms.TextBox tbFilename;
        private System.Windows.Forms.Panel panel1;
    }
}

