using System.Drawing;
using System.Windows.Forms;

namespace MicroMachinesEditor
{
    public sealed partial class ScrollingPanel : Panel
    {
        public ScrollingPanel()
        {
            AutoScroll = true;
        }

        protected override Point ScrollToControl(Control activeControl)
        {
            // Keep scroll position on focus
            return base.DisplayRectangle.Location;
        }
    }
}
