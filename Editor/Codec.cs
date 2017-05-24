using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Drawing;
using System.Linq;
using System.Text;

namespace MicroMachinesEditor
{
    /// <summary>
    /// Handles the compression/decompression and encoding for Micro Machines.
    /// </summary>
    static class Codec
    {
        public static List<byte> Decompress(IList<byte> data, int offset, StringBuilder sb = null)
        {
            var bufferHelper = new BufferHelper(data, offset);
            return Decompress(bufferHelper, sb);
        }

        public static List<byte> Decompress(BufferHelper data, StringBuilder sb = null)
        {
            var result = new List<byte>();
            for (;;)
            {
                sb?.AppendLine($"Getting mask from {data.Offset:X}");
                byte mask = data.Next();
                // Iterate over its bits, left to right
                for (int i = 7; i >= 0; --i)
                {
                    sb?.AppendLine($"Next data from {data.Offset:X}");
                    if (!IsBitSet(mask, i))
                    {
                        // Raw byte
                        byte b = data.Next();
                        result.Add(b);
                        sb?.AppendLine($"Bit 0: raw {b:X2}");
                    }
                    else
                    {
                        // Something more complicated
                        byte controlByte = data.Next();
                        sb?.Append($"Bit 1: {controlByte:X2} ");
                        if (AreAllBitsSet(controlByte))
                        {
                            // End of data
                            sb?.AppendLine("= end of data");
                            return result;
                        }
                        int highNibble = controlByte >> 4;
                        int lowNibble = controlByte & 0xf;
                        switch (highNibble)
                        {
                            case 0:
                                ProcessRawRun(result, data, lowNibble, sb);
                                // We want to re-use the mask bit so we do this to cancel out the decrement above
                                ++i;
                                break;
                            case 1:
                                ProcessRLE(result, data, lowNibble, sb);
                                break;
                            case 2:
                                ProcessLZ(result, data, lowNibble, 2, sb);
                                break;
                            case 3:
                                ProcessLZ(result, data, lowNibble, 256 + 2, sb);
                                break;
                            case 4:
                                ProcessLZ(result, data, lowNibble, 512 + 2, sb);
                                break;
                            case 5:
                                ProcessBigLZ(result, data, lowNibble, sb);
                                break;
                            case 6:
                                ProcessReverseLZ(result, data, lowNibble, sb);
                                break;
                            case 7:
                                ProcessIncrementingRun(result, data, lowNibble, sb);
                                break;
                            default: // 8-F
                                ProcessTinyLZ(result, controlByte, sb);
                                break;
                        }
                    }
                }
            }
        }

        private static void ProcessTinyLZ(IList<byte> result, byte controlByte, StringBuilder sb)
        {
            // %1nnooooo = copy n+2 bytes from relative offset -(o+n+2)
            int runLength = ((controlByte >> 5) & 0x03) + 2;
            int runOffset = ((controlByte >> 0) & 0x1f) + runLength;
            LZCopy(result, runLength, runOffset, sb);
        }

        private static void ProcessIncrementingRun(IList<byte> result, BufferHelper data, int lowNibble, StringBuilder sb)
        {
            // _F nn = emit nn + 17 bytes incrementing from last value written
            // _n    = emit n + 2 bytes incrementing from last value written
            byte value = result[result.Count - 1];
            int runLength;
            if (lowNibble == 0xf)
            {
                var b = data.Next();
                runLength = b + 17;
                sb?.Append($"{b:X2} ");
            }
            else
            {
                runLength = lowNibble + 2;
            }
            sb?.AppendLine($"= incrementing from {value + 1:X2} to {value + runLength:X2}");
            for (int i = 0; i < runLength; ++i)
            {
                result.Add(++value);
            }
        }

        private static void ProcessReverseLZ(IList<byte> result, BufferHelper data, int lowNibble, StringBuilder sb)
        {
            // 6x oo = copy x+3 bytes from oo+1 bytes earlier in the output stream, going backwards
            int runLength = lowNibble + 3;
            int runOffset = data.Next() + 1;
            sb?.Append($"{runOffset-1:X2} = reverse LZ offset {runOffset} length {runLength}:");
            int copyOffset = result.Count - runOffset;
            for (int i = 0; i < runLength; ++i)
            {
                var b = result[copyOffset--];
                result.Add(b);
                sb?.Append($" {b:X2}");
            }
            sb?.AppendLine();
        }

        private static void ProcessBigLZ(IList<byte> result, BufferHelper data, int lowNibble, StringBuilder sb)
        {
            // 5f hh oo cc = copy c+4 bytes from relative offset -(h*256+o+1)
            // 5x oo cc    = copy c+4 bytes from relative offset -(x*256+o+1)
            int runOffset;
            if (lowNibble == 0x0f)
            {
                var h = data.Next();
                var l = data.Next();
                sb?.Append($"{h:X2} {l:X2} ");
                runOffset = h * 256 + l + 1;
            }
            else
            {
                var o = data.Next();
                sb?.Append($"{o:X2} ");
                runOffset = lowNibble * 256 + o + 1;
            }
            var b = data.Next();
            sb?.Append($"{b:X2} ");
            int runLength = b + 4;
            LZCopy(result, runLength, runOffset, sb);
        }

        private static void ProcessLZ(IList<byte> result, BufferHelper data, int lowNibble, int shift, StringBuilder sb)
        {
            // 2x nn = copy x+3 bytes from relative offset -(nn+2)
            // 3x nn = copy x+3 bytes from relative offset -(nn+2+256)
            // 4x nn = copy x+3 bytes from relative offset -(nn+2+512)
            var b = data.Next();
            int runLength = lowNibble + 3;
            int runOffset = b + shift;
            sb?.Append($"{b:X2} ");
            LZCopy(result, runLength, runOffset, sb);
        }

        private static void ProcessRLE(IList<byte> result, BufferHelper data, int lowNibble, StringBuilder sb)
        {
            // _F nn = repeat last written byte nn + 17 times
            // _n    = repeat last written byte n + 2 times
            byte valueToCopy = result[result.Count - 1];
            int repeatCount;
            if (lowNibble == 0xf)
            {
                var b = data.Next();
                repeatCount = b + 17;
                sb?.Append($"{b:X2} ");
            }
            else
            {
                repeatCount = lowNibble + 2;
            }
            for (int i = 0; i < repeatCount; ++i)
            {
                result.Add(valueToCopy);
            }
            sb?.AppendLine($"= RLE {repeatCount}: {valueToCopy:X2}...");
        }

        private static void ProcessRawRun(ICollection<byte> result, BufferHelper data, int lowNibble, StringBuilder sb)
        {
            // _F FF nnnn = length nnnn    (n = 0..ffff -> length =  0 .. 65535)
            // _F nn      = length nn + 30 (n = 0..fe   -> length = 30 ..   284)
            // _n         = length n + 8   (n = 0..e    -> length =  8 ..    22) (gap!)
            int length;
            if (lowNibble == 0x0f)
            {
                length = data.Next();
                sb?.Append($"{length:X2} ");
                if (length == 0xff)
                {
                    length = data.Next() + (data.Next() << 8);
                    sb?.Append($"{length:X4} = raw {length} bytes");
                }
                else
                {
                    sb?.Append($"= raw {length + 30} bytes");
                    length += 30;
                }
            }
            else
            {
                length = lowNibble + 8;
                sb?.Append($"= raw {length} bytes");
            }
            sb?.Append(":");
            for (int i = 0; i < length; ++i)
            {
                var b = data.Next();
                result.Add(b);
                sb?.Append($" {b:X2}");
            }
            sb?.AppendLine();
        }

        private static void LZCopy(IList<byte> buffer, int runLength, int runOffset, StringBuilder sb)
        {
            sb?.Append($"= LZ offset {runOffset} length {runLength}:");
            // The source and dest may overlap! So we do a dumb copy.
            int fromIndex = buffer.Count - runOffset;
            if (fromIndex < 0)
            {
                throw new Exception("Invalid LZ offset");
            }
            for (int i = 0; i < runLength; ++i)
            {
                var b = buffer[fromIndex++];
                buffer.Add(b);
                sb?.Append($" {b:X2}");
            }
            sb?.AppendLine();
        }

        private static bool IsBitSet(byte b, int index)
        {
            int mask = 1 << index;
            return (b & mask) == mask;
        }

        private static bool AreAllBitsSet(byte b)
        {
            return b == 0xff;
        }

        public static int AbsoluteOffset(int pageNumber, int offset)
        {
            return (pageNumber - 2) * 16 * 1024 + offset;
        }

        public static IList<SMSGraphics.Tile> LoadTiles(byte[] file, int offset, IList<Color> palette)
        {
            // Decompress
            IList<byte> data = Decompress(file, offset);

            // The data is deinterleaved and only three bitplanes.
            // We make it into SMS VRAM format.
            int bytesPerBitplane = data.Count / 3;
            byte[] buffer = new byte[bytesPerBitplane * 4];
            // Interleave it
            for (int i = 0; i < bytesPerBitplane; ++i)
            {
                // Read in three bytes...
                byte b0 = data[i + bytesPerBitplane * 0];
                byte b1 = data[i + bytesPerBitplane * 1];
                byte b2 = data[i + bytesPerBitplane * 2];
                byte b3 = 0; // Fill it out
                // Write it out
                buffer[i * 4 + 0] = b0;
                buffer[i * 4 + 1] = b1;
                buffer[i * 4 + 2] = b2;
                buffer[i * 4 + 3] = b3;
            }
            // Then pass it on...
            return SMSGraphics.ReadTiles(buffer, 0, buffer.Length, palette);
        }

        /// <summary>
        /// Loads metatiles from the ROM
        /// </summary>
        /// <param name="file">ROM</param>
        /// <param name="trackType">Index as used by the game</param>
        /// <param name="tiles">Tiles for the metatiles to use</param>
        /// <returns>Metatiles</returns>
        public static IList<MetaTile> LoadMetaTiles(byte[] file, int trackType, IList<SMSGraphics.Tile> tiles)
        {
            var result = new List<MetaTile>();

            int pageNumber = TrackTypeDataPageNumber(file, trackType);

            // The metatile data per-track is in a table at 0x4225
            int metatileTableOffset = 0x4225 + trackType * 64;

            int trackDataOffset = pageNumber * 16 * 1024;
            int offsetBehaviourData = AbsoluteOffset(pageNumber, BitConverter.ToUInt16(file, trackDataOffset + 0));
            int offsetWallData = AbsoluteOffset(pageNumber, BitConverter.ToUInt16(file, trackDataOffset + 2));

            // Decode behaviour data
            IList<byte> behaviourData = Decompress(file, offsetBehaviourData);

            // Decode wall data
            IList<byte> wallData = Decompress(file, offsetWallData);

            // There are 64 metatiles, always.
            IList<byte> behaviourLookup = file.Skip(0x242e + trackType * 16).Take(16).ToList();
            for (int i = 0; i < 64; ++i)
            {
                // Get the metatile global index
                int index = file[metatileTableOffset + i];
                // Calculate the data offsets
                int offsetTiles = AbsoluteOffset(pageNumber, DecodeSplitPointer(file, 0x4000, 0x41, index));
                offsetBehaviourData = i * 36 + 4;
                offsetWallData = i * 18 + 4;

                // Create a metatile from it
                var metaTile = new MetaTile(file, offsetTiles, tiles, wallData, offsetWallData, behaviourData, offsetBehaviourData, behaviourLookup);

                // Add it to the list
                result.Add(metaTile);
            }

            return result;
        }

        private static int DecodeSplitPointer(IReadOnlyList<byte> file, int offsetTable, int tableDelta, int index)
        {
            return file[offsetTable + index] | (file[offsetTable + tableDelta + index] << 8);
        }

        private const string LookupLow = "ABCDEFGHIJKLMN PQRSTUVWXYZO123456789";
        private const string LookupHigh = "!-?";

        public static string DecodeString(byte[] file, int offset, int limit = 0)
        {
            string result = "";
            bool stopAtInvalid = limit == 0;
            for (int i = 0; stopAtInvalid || i < limit; ++i)
            {
                byte b = file[offset + i];
                if (b < LookupLow.Length)
                {
                    result += LookupLow[b];
                }
                else
                {
                    b -= 0xb4;
                    if (b < LookupHigh.Length)
                    {
                        result += LookupHigh[b];
                    }
                    else
                    {
                        if (stopAtInvalid)
                        {
                            return result;
                        }
                        result += '_';
                    }
                }
            }
            return result;
        }

        // Takes a string and removes any disallowed characters, and pads to the right length
        public static string ValidateString(string value, int width)
        {
            return value
                .Where(c => !LookupLow.Contains(c) && !LookupHigh.Contains(c))
                .Aggregate("", (current, c) => current + c)
                .PadRight(width, ' ')
                .Substring(0, width);
        }

        private static int TrackTypeDataPageNumber(IReadOnlyList<byte> file, int trackType)
        {
            return file[0x3e3a + trackType];
        }
        /*
        private enum ChunkType
        {
            RLE,
            LZ,
            ReverseLZ
        };
        /*
        private struct LZMatch
        {
            public int Length;
            public int Offset;
        }
        /*
        private enum MatchType
        {
            RLE,
            LZ,
            ReverseLZ,
            Count,
            Raw
        };
        */

        private class BitmaskHelper
        {
            private readonly IList<byte> _output;
            private int _bitsUsed = 8;
            private int _offset;
            private int? _lastBitSquashable;

            public BitmaskHelper(IList<byte> output)
            {
                _output = output;
            }

            public void PutBit(int bit)
            {
                if (_lastBitSquashable.HasValue && bit == _lastBitSquashable.Value)
                {
                    // "Squash" by not emitting this one
                    _lastBitSquashable = null;
                    return;
                }
                if (_bitsUsed == 8)
                {
                    // Emit a new byte
                    _output.Add(0);
                    // Remember its offset
                    _offset = _output.Count - 1;
                    // Reset the count
                    _bitsUsed = 0;
                }
                // Merge it in
                int newBitmask = _output[_offset] | ((bit & 1) << (7 - _bitsUsed));
                _output[_offset] = (byte)newBitmask;
                ++_bitsUsed;
                _lastBitSquashable = null;
            }

            public void PutSquashableBit(int i)
            {
                PutBit(i);
                _lastBitSquashable = i;
            }
        }

        private abstract class Match
        {
            // Where in the data it is (i.e. the end data run)
            public int Offset { get; protected set; } 
            // How many bytes it emits
            public int Length { get; protected set; }
            // How many bytes it is encoded to
            public int EncodedLength { get; set; }
            // The compression ratio
            public double CompressionRatio => (Length - EncodedLength + 0.125) / Length;


            internal bool Overlaps(Match other)
            {
                // Options:
                // [this] 
                //        [other] = false
                //
                // [this]
                //    [other]     = true
                //
                //     [this]
                // [other]        = true
                //
                //         [this]
                // [other]        = false
                //
                //      [this]
                //    [  other ]  = true
                //
                //    [  this  ]
                //      [other]   = true
                //
                // It's easiest to pick out the false ones and invert...
                bool thisBeforeOther = Offset + Length <= other.Offset;
                bool otherBeforeThis = other.Offset + other.Length <= Offset;
                return !(thisBeforeOther || otherBeforeThis);
            }

            // Get the encoded version of this match
            public abstract IEnumerable<byte> GetBytes(BitmaskHelper bitmaskHelper);

            public override string ToString()
            {
                return $"{GetType().Name} {Length} => {EncodedLength} @{Offset:X} ({CompressionRatio:P})";
            }
        }

        private class RLEMatch : Match
        {
            private RLEMatch(int length, int offset)
            {
                Length = length;
                Offset = offset;
                EncodedLength = length < 17 ? 1 : length < 272 ? 2 : 4;
            }

            // Create a match from the given offset, or null if there is no acceptable match
/*
            public static Match GetBestMatch(IList<byte> data, int offset)
            {
                int length = GetRLECount(data, offset);
                // Encoding                Size       Run length  Values
                // 1 bit + 1x              1.1 bytes  2..16       x = n - 2
                // 1 bit + 1f + xx         2.1 bytes  17..271     x = n - 17
                // 1 bit + 1f + ff + xxxx  3.1 bytes  0..65535    x = n
                const int minimum = 2;
                const int maximum = 65535;
                if (length < minimum)
                {
                    return null;
                }
                if (length > maximum)
                {
                    length = maximum;
                }
                return new RLEMatch(length, offset);
            }
*/

            public override IEnumerable<byte> GetBytes(BitmaskHelper bitmaskHelper)
            {
                bitmaskHelper.PutBit(1);
                switch (EncodedLength)
                {
                    case 1:
                        // 1n    = repeat last written byte n + 2 times (so range 2..16)
                        yield return (byte)(0x10 | (Length - 2));
                        break;
                    case 2:
                        // 1F nn = repeat last written byte nn + 17 times (so range 17..271)
                        yield return 0x1f;
                        yield return (byte)(Length - 17);
                        break;
                    case 4:
                        // 1F FF nn nn = repeat last written byte nnnn (so range 0..65535)
                        yield return 0x1f;
                        yield return 0xff;
                        yield return (byte)(Length >> 0);
                        yield return (byte)(Length >> 8);
                        break;
                    default:
                        throw new ArgumentOutOfRangeException(nameof(EncodedLength));
                }
            }

            public static IEnumerable<Match> GetAll(IList<byte> data, int offset)
            {
                // Returns *all* possible RLE matches starting at the given offset
                if (offset == 0)
                {
                    // Need a reference byte, so we return an empty collection
                    yield break;
                }
                byte b = data[offset - 1];
                for (int i = offset; i < data.Count; ++i)
                {
                    if (data[i] != b)
                    {
                        // No match, no more RLE
                        yield break;
                    }
                    int length = i - offset + 1;
                    if (length < 2 || length > 65535)
                    {
                        continue;
                    }
                    yield return new RLEMatch(length, offset);
                }
            }
        }

        private class IncrementingMatch : Match
        {
            private IncrementingMatch(int length, int offset)
            {
                Length = length;
                Offset = offset;
                EncodedLength = length < 17 ? 1 : 2;
            }

            // Create a match from the given offset, or null if there is no acceptable match
/*
            public static Match GetBestMatch(IList<byte> data, int offset)
            {
                int length = GetCountingRun(data, offset);
                const int minimum = 2;
                const int maximum = 255 + 17;
                if (length < minimum)
                {
                    return null;
                }
                if (length > maximum)
                {
                    length = maximum;
                }
                return new IncrementingMatch(length, offset);
            }
*/

            public override IEnumerable<byte> GetBytes(BitmaskHelper bitmaskHelper)
            {
                bitmaskHelper.PutBit(1);
                switch (EncodedLength)
                {
                    case 1:
                        // 7n    = repeat last written byte n + 2 times (range 2..16)
                        yield return (byte) (0x70 | (Length - 2));
                        break;
                    case 2:
                        // 7F nn = repeat last written byte nn + 17 times (range 17..272)
                        yield return 0x7f;
                        yield return (byte) (Length - 17);
                        break;
                    default:
                        throw new ArgumentOutOfRangeException(nameof(EncodedLength));
                }
            }

            public static IEnumerable<Match> GetAll(IList<byte> data, int offset)
            {
                if (offset == 0)
                {
                    yield break;
                }
                const int minimum = 2;
                const int maximum = 255 + 17;
                byte b = data[offset - 1];
                for (int i = offset; i < data.Count; ++i)
                {
                    if (data[i] != ++b || i > maximum)
                    {
                        yield break;
                    }
                    if (i >= minimum)
                    {
                        yield return new IncrementingMatch(i, offset);
                    }
                }
            }
        }

        private class RawMatch : Match
        {
            private IList<byte> Data { get; }

            public RawMatch(IList<byte> data, int offset, int length)
            {
                Data = data;
                Offset = offset;
                Length = length;
                EncodedLength = length;
                if (length < 8)
                {
                    EncodedLength += 0; // Ignores the bits used to encode the length
                }
                else if (length < 22)
                {
                    EncodedLength += 1; // To encode the length...
                }
                else if (length < 255 + 30)
                {
                    EncodedLength += 2;
                }
                else
                {
                    EncodedLength += 4;
                }
            }

            public override IEnumerable<byte> GetBytes(BitmaskHelper bitmaskHelper)
            {
                if (Length < 8)
                {
                    // Bitmask-encoded raw
                    for (int i = 0; i < Length; ++i)
                    {
                        bitmaskHelper.PutBit(0);
                        yield return Data[Offset + i];
                    }
                    yield break;                    
                }

                if (Length >= 15 + 8 && Length < 30)
                {
                    // Runs between 23 and 30 inclusive need to be emitted as two runs (!).
                    // We construct the split runs, emit their data and exit.
                    var first = new RawMatch(Data, Offset, 8);
                    var second = new RawMatch(Data, Offset + 8, Length - 8);
                    foreach (var b in first.GetBytes(bitmaskHelper).Concat(second.GetBytes(bitmaskHelper)))
                    {
                        yield return b;
                    }
                    yield break;
                }

                // "Encoded" raw
                // This latches onto the mask bit of the block following it, but it needs to be pushed now
                // as a "squashable" bit
                bitmaskHelper.PutSquashableBit(1);
                if (Length < 15 + 8)
                {
                    // 0n         = length n + 8
                    yield return (byte)(Length - 8);
                }
                else if (Length < 255 + 30)
                {
                    // 0F nn      = length nn + 30
                    yield return 0x0f;
                    yield return (byte)(Length - 30);
                }
                else
                {
                    // 0F FF nnnn = length nnnn
                    yield return 0x0f;
                    yield return 0xff;
                    yield return (byte)(Length & 0xff);
                    yield return (byte)(Length >> 8);
                }

                // Then relay the bytes back
                for (int i = 0; i < Length; ++i)
                {
                    yield return Data[Offset + i];
                }
            }
        }

        private class LZMatch : Match
        {
            private const int InvalidLength = 1000;

            protected LZMatch(int length, int offset, int matchOffset)
            {
                Length = length;
                Offset = offset;
                Distance = offset - matchOffset;
                // We calculate the encoded length (and validity) here
                // Different LZ options have different limits:
                //
                // Type     Length      LZDistance                Size  Encoding                              Adjustments
                //          Min    Max       Min             Max
                // Tiny     0+2    3+2  Length+0     Length+0x1f  1     %1LLDDDDD                             L = length - 2, D = distance - length
                // Medium2  0+3   15+3       0+2           255+2  2     %0010LLLL DDDDDDDD                    L = length - 3, D = distance - 2
                // Medium3  0+3   15+3     256+2       256+255+2  2     %0011LLLL DDDDDDDD                    L = length - 3, D = distance - 258
                // Medium4  0+3   15+3     512+2       512+255+2  2     %0100LLLL DDDDDDDD                    L = length - 3, D = distance - 514
                // Big5x    0+4  255+4       0+1   0xe*256+255+1  3     %0101DDDD DDDDDDDD LLLLLLLL           L = length - 4, D = distance - 1
                // Big5f    0+4  255+4       0+1   255*256+255+1  4     %01011111 DDDDDDDD DDDDDDDD LLLLLLLL  L = length - 4, D = distance - 1
                EncodedLength = InvalidLength;
                if (Length >= 0+2 && Length <= 3+2 && Distance >= Length && Distance <= Length + 0x1f && !(Length - 2 == 3 && Distance - Length == 0x1f))
                {
                    EncodedLength = 1;
                }
                else if (Length >= 0+3 && Length <= 0xf+3 && Distance >= 0+2 && Distance <= 0x2ff+2)
                {
                    EncodedLength = 2;
                }
                else if (Length >= 0+4 && Length <= 0xff+4 && Distance >= 0+1)
                {
                    if (Distance <= 0xeff + 1)
                    {
                        EncodedLength = 3;
                    }
                    else if (Distance <= 0xffff+1)
                    {
                        EncodedLength = 4;
                    }
                }
            }

            public int Distance { get; }

/*
            private static LZMatch GetBestMatch(IList<byte> data, int offset, int encodedLength, int minDistance, int maxDistance, int minLength, int maxLength, Func<int, int, bool> validator = null )
            {
                // We walk backwards looking for the longest match in the given constraints
                int minOffset = Math.Max(0, offset - maxDistance);
                int maxOffset = offset - minDistance;
                int bestLength = 0;
                int bestOffset = 0;
                for (int i = maxOffset; i >= minOffset; --i)
                {
                    // Check for a match
                    int matchLength = 0;
                    for (; offset + matchLength < data.Count; ++matchLength)
                    {
                        byte wanted = data[offset + matchLength];
                        byte have = data[i + matchLength];
                        if (wanted != have)
                        {
                            break;
                        }
                    }
                    if (matchLength > bestLength && (validator == null || validator(matchLength, offset - i)))
                    {
                        bestLength = matchLength;
                        bestOffset = i;
                        if (bestLength >= maxLength)
                        {
                            bestLength = maxLength;
                            break;
                        }
                    }
                }
                if (bestLength >= minLength)
                {
                    return new LZMatch(bestLength, offset, bestOffset) {EncodedLength = encodedLength};
                }
                return null;
            }
*/

/*
            private static bool IsValidTiny(int length, int distance)
            {
                // We return whether we are happy to encode it
                var lengthBits = length - 2;
                var distanceBits = distance - length;
                return ((lengthBits | 0x3) == 0x3) && // Only two bits used
                       ((distanceBits | 0x1f) == 0x1f) && // Only 5 bits used
                       (lengthBits != 0x3 || distanceBits != 0x1f); // bits are not all 1
            }
*/

            // Create a match from the given offset, or null if there is no acceptable match
/*
            public static LZMatch GetBestMatch(IList<byte> data, int offset)
            {
                // Different LZ options have different limits:
                //
                // Type     Length      LZDistance                Size  Encoding                              Adjustments
                //          Min    Max       Min             Max
                // Tiny     0+2    3+2  Length+0     Length+0x1f  1     %1LLDDDDD                             L = length - 2, D = distance - length
                // Medium2  0+3   16+3       0+2           255+2  2     %0010LLLL DDDDDDDD                    L = length - 3, D = distance - 2
                // Medium3  0+3   16+3     256+2       256+255+2  2     %0011LLLL DDDDDDDD                    L = length - 3, D = distance - 258
                // Medium4  0+3   16+3     512+2       512+255+2  2     %0100LLLL DDDDDDDD                    L = length - 3, D = distance - 514
                // Big5x    0+4  255+4       0+1  0xef*256+255+1  3     %0101DDDD DDDDDDDD LLLLLLLL           L = length - 4, D = distance - 1
                // Big5f    0+4  255+4       0+1   255*256+255+1  4     %01011111 DDDDDDDD DDDDDDDD LLLLLLLL  L = length - 4, D = distance - 1

                // We find the best match for each encoding length
                var matches = new[]
                { //                              Distance min ---------- max             Length min ---- max
                    GetBestMatch(data, offset, 1,    0x00 + 0x0 + 2,     0x1f + 0x3 + 2,     0x0 + 2,    0x3 + 2, IsValidTiny),
                    GetBestMatch(data, offset, 2,    0x00 + 2,           0xff + 2,           0x0 + 3,    0xf + 3),
                    GetBestMatch(data, offset, 2,   0x100 + 2,          0x1ff + 2,           0x0 + 3,    0xf + 3),
                    GetBestMatch(data, offset, 2,   0x200 + 2,          0x2ff + 2,           0x0 + 3,    0xf + 3),
                    GetBestMatch(data, offset, 3,   0x000 + 1,          0xeff + 1,          0x00 + 4,   0xff + 4),
                    GetBestMatch(data, offset, 4,  0x0000 + 1,         0xffff + 1,          0x00 + 4,   0xff + 4)
                };

                // Pick the one with the best savings
                return matches
                    .Where(x => x != null && x.EncodedLength < x.Length)
                    .OrderByDescending(x => x.Length - x.EncodedLength)
                    .ThenBy(x => x.EncodedLength)
                    .FirstOrDefault();
            }
*/

            public override IEnumerable<byte> GetBytes(BitmaskHelper bitMaskHelper)
            {
                bitMaskHelper.PutBit(1);
                switch (EncodedLength)
                {
                    case 1:
                        // %1nnooooo = copy n+2 bytes from relative offset -(o+n+2)
                        yield return (byte)(0x80 | ((Length - 2) << 5) | (Distance - Length));
                        break;
                    case 2:
                        if (Distance <= 255 + 2)
                        {
                            // 2x nn = copy x+3 bytes from relative offset -(nn+2)
                            yield return (byte)(0x20 | (Length - 3));
                            yield return (byte)(Distance - 2);
                        }
                        else if (Distance <= 255 + 2 + 256)
                        {
                            // 3x nn = copy x+3 bytes from relative offset -(nn+2+256)
                            yield return (byte)(0x30 | (Length - 3));
                            yield return (byte)(Distance - 2 - 256);
                        }
                        else if (Distance <= 255 + 2 + 512)
                        {
                            // 4x nn = copy x+3 bytes from relative offset -(nn+2+512)
                            yield return (byte)(0x40 | (Length - 3));
                            yield return (byte)(Distance - 2 - 512);
                        }
                        else
                        {
                            throw new Exception("Invalid LZMatch");
                        }
                        break;
                    case 3:
                        // 5x oo cc    = copy c+4 bytes from relative offset -(x*256+o+1)
                        yield return (byte)(0x50 | ((Distance - 1) >> 8));
                        yield return (byte)((Distance - 1) & 0xff);
                        yield return (byte)(Length - 4);
                        break;
                    case 4:
                        // 5f hh oo cc = copy c+4 bytes from relative offset -(h*256+o+1)
                        yield return 0x5f;
                        yield return (byte)((Distance - 1) >> 8);
                        yield return (byte)((Distance - 1) & 0xff);
                        yield return (byte)(Length - 4);
                        break;
                    default:
                        throw new ArgumentOutOfRangeException(nameof(EncodedLength));
                }
            }

            public override string ToString()
            {
                return $"{base.ToString()}, {nameof(Distance)}: {Distance}";
            }

            public static IEnumerable<Match> GetAll(IList<byte> data, int offset)
            {
                // We walk backwards looking for matches, and emit the most efficient one for every length
                const int minDistance = 1;
                const int maxDistance = 65536;
                const int minLength = 2;
                const int maxLength = 259;
                int minOffset = Math.Max(0, offset - maxDistance);
                int maxOffset = offset - minDistance;
                for (int matchOffset = maxOffset; matchOffset >= minOffset; --matchOffset)
                {
                    // Check for a match
                    for (int matchLength = 0; offset + matchLength < data.Count; /* increment in loop */)
                    {
                        byte wanted = data[offset + matchLength];
                        byte have = data[matchOffset + matchLength];
                        if (wanted != have)
                        {
                            break;
                        }
                        // There is a match
                        ++matchLength;
                        if (matchLength < minLength)
                        {
                            continue;
                        }
                        var match = new LZMatch(matchLength, offset, matchOffset);
                        if (match.EncodedLength != InvalidLength)
                        {
                            yield return match;
                        }
                        if (matchLength >= maxLength)
                        {
                            break;
                        }
                    }
                }
            }
        }

        private class ReverseLZMatch : LZMatch
        {
            private ReverseLZMatch(int length, int offset, int matchOffset) : base(length, offset, matchOffset)
            {}

/*
            public static Match GetBestMatch(IList<byte> data, int offset)
            {
                var match = GetReverseLZMatch(data, offset);
                if (match.Length < 3)
                {
                    // Not worth having (and can't encode it)
                    return null;
                }
                if (match.Length > 15 + 3)
                {
                    match.Length = 15 + 3; //  maximum length
                }
                match.EncodedLength = 2;
                return match;
            }
*/

            public override IEnumerable<byte> GetBytes(BitmaskHelper bitMaskHelper)
            {
                bitMaskHelper.PutBit(1);
                // 6x oo = copy x+3 bytes from oo+1 bytes earlier in the output stream, going backwards
                yield return (byte)(0x60 | (Length - 3));
                yield return (byte)(Distance - 1);
            }

            public new static IEnumerable<Match> GetAll(IList<byte> data, int offset)
            {
                // We walk backwards looking for matches, and emit one for every length
                const int minDistance = 1;
                const int maxDistance = 256;
                const int minLength = 3;
                const int maxLength = 18;
                int minOffset = Math.Max(0, offset - maxDistance);
                int maxOffset = offset - minDistance;
                for (int i = maxOffset; i >= minOffset; --i)
                {
                    // Check for a match
                    for (int matchLength = 0; i - matchLength >= 0 && offset + matchLength < data.Count; /* increment in loop */)
                    {
                        byte wanted = data[offset + matchLength];
                        byte have = data[i - matchLength];
                        if (wanted != have)
                        {
                            break;
                        }
                        ++matchLength;
                        if (matchLength >= minLength)
                        {
                            yield return new ReverseLZMatch(matchLength, offset, i);
                        }
                        if (matchLength == maxLength)
                        {
                            break;
                        }
                    }
                }
            }
        }

        public static IList<byte> CompressForwards(IList<byte> data)
        {
            // For forward compression, we just walk through the data and pick the best option as it appears.
            // This is a lot faster than the exhaustive option, and yields pretty similar results.
            // TODO this is not as good as it used to be - maybe due to bug that made it work better before by removing greedier matches.
            // TODO the way we work here is to pick the best of the 
            var matches = new List<Match>();
            Trace.WriteLine("Collecting matches...");
            for (int i = 0; i < data.Count; ++i)
            {
                var best = new[]
                    {
                        RLEMatch.GetAll(data, i).LastOrDefault(),
                        IncrementingMatch.GetAll(data, i).LastOrDefault(),
                        LZMatch.GetAll(data, i)
                            .OrderByDescending(x => x.Length - x.EncodedLength)
                            .ThenByDescending(x => x.Length)
                            .FirstOrDefault(),
                        ReverseLZMatch.GetAll(data, i).LastOrDefault()
                    }
                    .Where(x => x != null)
                    .OrderByDescending(x => x.Length - x.EncodedLength)
                    .ThenByDescending(x => x.Length)
                    .FirstOrDefault();
                if (best != null)
                {
                    matches.Add(best);
                    i += best.Length - 1;
                }
            }
            return Compress(data, matches);
        }

        public static IList<byte> Compress(IList<byte> data)
        {
            // We create a list of all the compressible parts in the data
            var matches = new List<Match>();
            Trace.WriteLine("Collecting matches...");
            for (int i = 0; i < data.Count; ++i)
            {
                matches.AddRange(RLEMatch.GetAll(data, i));
                matches.AddRange(IncrementingMatch.GetAll(data, i));
                matches.AddRange(LZMatch.GetAll(data, i));
                matches.AddRange(ReverseLZMatch.GetAll(data, i));
            }
            Trace.WriteLine($"Found {matches.Count} matches. Ordering by \"best\"...");

            List<Match> compressedChunks = new List<Match>();
            // We then want to choose the "best" blocks to use, which is very hard to do perfectly - because 
            // any given chunk may "eat into" another "lesser" one, resulting in a less efficient result.
            // We could waste a bunch of CPU randomising the choice, but that'd quickly get silly.
            // Strategy 1: pick the ones with the best savings ratio
            // 2136
            //matches = matches.OrderByDescending(match => match.CompressionRatio).ThenBy(match => match.Offset).ToList();
            // Strategy 2: pick the biggest savings at the current point, preferring longer matches
            // 2085
            // matches = matches.OrderBy(match => match.Offset).ThenByDescending(match => match.Length - match.EncodedLength).ThenByDescending(match => match.Length).ToList();
            // Strategy 3: pick the ones with the biggest savings by byte count
            // 2065
            matches = matches.OrderByDescending(match => match.Length - match.EncodedLength)
                .ThenBy(match => match.Offset)
                .ToList();

            while (matches.Count > 0)
            {
                // Then pick the longest
                Match bestMatch = matches.First();

                Trace.WriteLine(
                    $"Match at {bestMatch.Offset:X} of length {bestMatch.Length:X} is type {bestMatch.GetType().Name}, best of {matches.Count} remaining");

                // Add it to our list
                compressedChunks.Add(bestMatch);

                // Then we want to remove any matches that overlapped it, since they are no longer needed
                matches.RemoveAll(x => x.Overlaps(bestMatch));

                // And repeat
            }
            Trace.WriteLine($"Reduced to {compressedChunks.Count}, sorting...");

            // Then order by offset, ascending
            compressedChunks.Sort((a, b) => a.Offset - b.Offset);

            return Compress(data, compressedChunks);
        }

        private static IList<byte> Compress(IList<byte> data, List<Match> compressedChunks)
        {
            // Then we loop over the chunks and insert "raw" chunks in the gaps
            Trace.WriteLine("Adding raw chunks...");
            List<Match> allChunks = new List<Match>();
            int offset = 0;
            foreach (Match compressedChunk in compressedChunks)
            {
                int chunkOffset = compressedChunk.Offset;
                if (chunkOffset > offset)
                {
                    // Emit a raw chunk
                    allChunks.Add(new RawMatch(data, offset, chunkOffset - offset));
                }
                allChunks.Add(compressedChunk);
                offset = compressedChunk.Offset + compressedChunk.Length;
            }
            // Add a final raw chunk if needed
            if (offset < data.Count)
            {
                allChunks.Add(new RawMatch(data, offset, data.Count - offset));
            }

            // Then emit them all
            Trace.WriteLine($"Emitting {allChunks.Count} encoded chunks...");
            List<byte> result = new List<byte>();
            BitmaskHelper bitmaskHelper = new BitmaskHelper(result);
            foreach (Match chunk in allChunks)
            {
                // Have to do this byte-wise to get the bitstream bytes interleaved
                foreach (var b in chunk.GetBytes(bitmaskHelper))
                {
                    result.Add(b);
                }
            }
            
            // Finally add a terminator
            bitmaskHelper.PutBit(1);
            result.Add(0xff);

            return result;
        }

/*
        private static int GetCountingRun(IList<byte> data, int start)
        {
            if (start == 0)
            {
                return 0;
            }
            byte b = data[start - 1];
            int offset = start;
            for (; offset < data.Count; ++offset)
            {
                if (data[offset] != ++b)
                {
                    break;
                }
            }
            return offset - start;
        }
*/

/*
        private static ReverseLZMatch GetReverseLZMatch(IList<byte> data, int offset)
        {
            int bestLength = 0;
            int bestOffset = 0;
            // We do a dumb walk backwards through the data
            int minOffset = Math.Max(offset - 256, 0);
            for (int i = offset - 1; i >= minOffset; --i)
            {
                // Check for a match
                int matchLength = 0;
                for (; i - matchLength >= 0 && offset + matchLength < data.Count; ++matchLength)
                {
                    byte wanted = data[offset + matchLength];
                    byte have = data[i - matchLength];
                    if (wanted != have)
                    {
                        break;
                    }
                }
                if (matchLength > bestLength)
                {
                    bestLength = matchLength;
                    bestOffset = i;
                }
            }
            return new ReverseLZMatch(bestLength, offset, bestOffset);
        }
*/

/*
        private static LZMatch GetLZMatch(IList<byte> data, int offset)
        {
            int bestLength = 0;
            int bestOffset = 0;
            // We want to prefer matches which are closer, as they can encode smaller.
            // So we should walk backwards to look.
            // TODO: we should actually find matches for all encoding lengths?
            for (int i = 0; i < offset; ++i)
            {
                // Check for a match
                int matchLength = 0;
                for (; offset + matchLength < data.Count; ++matchLength)
                {
                    byte wanted = data[offset + matchLength];
                    byte have = data[i + matchLength];
                    if (wanted != have)
                    {
                        break;
                    }
                }
                if (matchLength > bestLength)
                {
                    bestLength = matchLength;
                    bestOffset = i;
                }
            }
            return new LZMatch { Length = bestLength, Distance = offset - bestOffset, Offset = offset };
        }
*/

/*
        private static int GetRLECount(IList<byte> data, int start)
        {
            if (start == 0)
            {
                // Need a reference byte
                return 0;
            }
            byte b = data[start - 1];
            for (int i = start; i < data.Count; ++i)
            {
                if (data[i] != b)
                {
                    return i - start;
                }
            }
            return data.Count - start;
        }
*/
/*
        public static IList<byte> CompressSimple(IList<byte> data)
        {
            List<byte> output = new List<byte>();
            BitmaskHelper bitmaskHelper = new BitmaskHelper(output);
            // Walk through the data
            for (int i = 0; i < data.Count; ++i)
            {
                // Look for the best match from where we are
                // If there is nothing, push a raw byte.
                // We will coalesce the raw bytes later.
                int bestReduction = 0; // Number of bytes saved. We want to maximise this.

            }
        }
*/

        public static IList<byte> DecompressRLE(BufferHelper bufferHelper)
        {
            // TODO
            return new List<byte>();
        }
    }
}
