using System.Collections.Generic;

namespace MicroMachinesEditor
{
    /// <summary>
    /// Wraps a binary blob and exposes Offset, Next() and HasNext() methods for it
    /// </summary>
    class BufferHelper
    {
        public BufferHelper(IList<byte> data, int offset)
        {
            _data = data;
            Offset = offset;
        }

        public bool HasNext() { return Offset < _data.Count; }

        public byte Next() { return _data[Offset++]; }

        private readonly IList<byte> _data;

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
