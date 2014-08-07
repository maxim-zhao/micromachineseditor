using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MicroMachinesEditor
{
    class BufferHelper
    {
        public BufferHelper(IList<byte> data, int offset)
        {
            m_data = data;
            Offset = offset;
        }

        public bool HasNext() { return Offset < m_data.Count; }

        public byte Next() { return m_data[Offset++]; }

        private IList<byte> m_data;

        public int Offset { get; set; }
        /*
        internal byte[] Since(int when)
        {
            int length = Offset - when;
            byte[] result = new byte[length];
            Array.Copy(m_data, when, result, 0, length);
            return result;
        }
         * */
    }
}
