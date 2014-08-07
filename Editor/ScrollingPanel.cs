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
    public partial class ScrollingPanel : Panel
    {
        public ScrollingPanel()
        {
            this.AutoScroll = true;
        }

        protected override Point ScrollToControl(Control activeControl)
        {
            // Do nothing
            return this.DisplayRectangle.Location;
        }
    }
}
