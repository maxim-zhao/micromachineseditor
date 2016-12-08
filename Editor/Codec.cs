using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;

namespace MicroMachinesEditor
{
    /// <summary>
    /// Handles the compression/decompression and encoding for Micro Machines.
    /// </summary>
    static class Codec
    {
        public static List<byte> Decompress(IList<byte> data, int offset)
        {
            var bufferHelper = new BufferHelper(data, offset);
            return Decompress(bufferHelper);
        }

        public static List<byte> Decompress(BufferHelper data)
        {
            var result = new List<byte>();
            for (;;)
            {
                byte mask = data.Next();
                // Iterate over its bits, left to right
                for (int i = 7; i >= 0; --i)
                {
                    if (!IsBitSet(mask, i))
                    {
                        // Raw byte
                        byte b = data.Next();
                        result.Add(b);
                    }
                    else
                    {
                        // Something more complicated
                        byte controlByte = data.Next();
                        if (AreAllBitsSet(controlByte))
                        {
                            // End of data
                            return result;
                        }
                        int highNibble = controlByte >> 4;
                        int lowNibble = controlByte & 0xf;
                        switch (highNibble)
                        {
                            case 0:
                                ProcessRawRun(result, data, lowNibble);
                                // We want to re-use the mask bit so we do this to cancel out the decrement above
                                ++i;
                                break;
                            case 1:
                                ProcessRLE(result, data, lowNibble);
                                break;
                            case 2:
                                ProcessLZ(result, data, lowNibble, 2);
                                break;
                            case 3:
                                ProcessLZ(result, data, lowNibble, 256 + 2);
                                break;
                            case 4:
                                ProcessLZ(result, data, lowNibble, 512 + 2);
                                break;
                            case 5:
                                ProcessBigLZ(result, data, lowNibble);
                                break;
                            case 6:
                                ProcessReverseLZ(result, data, lowNibble);
                                break;
                            case 7:
                                ProcessIncrementingRun(result, data, lowNibble);
                                break;
                            default: // 8-F
                                ProcessTinyLZ(result, controlByte);
                                break;
                        }
                    }
                }
            }
        }

        private static void ProcessTinyLZ(List<byte> result, byte controlByte)
        {
            // %1nnooooo = copy n+2 bytes from relative offset -(o+n+2)
            int runLength = ((controlByte >> 5) & 0x03) + 2;
            int runOffset = ((controlByte >> 0) & 0x1f) + runLength;
            LZCopy(result, runLength, runOffset);
        }

        private static void ProcessIncrementingRun(List<byte> result, BufferHelper data, int lowNibble)
        {
            // _F nn = emit nn + 17 bytes incrementing from last value written
            // _n    = emit n + 2 bytes incrementing from last value written
            byte value = result[result.Count - 1];
            int runLength;
            if (lowNibble == 0xf)
            {
                runLength = data.Next() + 17;
            }
            else
            {
                runLength = lowNibble + 2;
            }
            for (int i = 0; i < runLength; ++i)
            {
                result.Add(++value);
            }
        }

        private static void ProcessReverseLZ(List<byte> result, BufferHelper data, int lowNibble)
        {
            // 6x oo = copy x+3 bytes from oo+1 bytes earlier in the output stream, going backwards
            int runLength = lowNibble + 3;
            int runOffset = data.Next() + 1;
            int copyOffset = result.Count - runOffset;
            for (int i = 0; i < runLength; ++i)
            {
                result.Add(result[copyOffset--]);
            }
        }

        private static void ProcessBigLZ(List<byte> result, BufferHelper data, int lowNibble)
        {
            // 5f hh oo cc = copy c+4 bytes from relative offset -(h*256+o+1)
            // 5x oo cc    = copy c+4 bytes from relative offset -(x*256+o+1)
            int runOffset;
            if (lowNibble == 0x0f)
            {
                runOffset = data.Next() * 256 + data.Next() + 1;
            }
            else
            {
                runOffset = lowNibble * 256 + data.Next() + 1;
            }
            int runLength = data.Next() + 4;
            LZCopy(result, runLength, runOffset);
        }

        private static void ProcessLZ(List<byte> result, BufferHelper data, int lowNibble, int shift)
        {
            // 2x nn = copy x+3 bytes from relative offset -(nn+2)
            // 3x nn = copy x+3 bytes from relative offset -(nn+2+256)
            // 4x nn = copy x+3 bytes from relative offset -(nn+2+512)
            int runLength = lowNibble + 3;
            int runOffset = data.Next() + shift;
            LZCopy(result, runLength, runOffset);
        }

        private static void ProcessRLE(List<byte> result, BufferHelper data, int lowNibble)
        {
            // _F nn = repeat last written byte nn + 17 times
            // _n    = repeat last written byte n + 2 times
            byte valueToCopy = result[result.Count - 1];
            int repeatCount;
            if (lowNibble == 0xf)
            {
                repeatCount = data.Next() + 17;
            }
            else
            {
                repeatCount = lowNibble + 2;
            }
            for (int i = 0; i < repeatCount; ++i)
            {
                result.Add(valueToCopy);
            }
        }

        private static void ProcessRawRun(List<byte> result, BufferHelper data, int lowNibble)
        {
            // _F FF nnnn = length nnnn
            // _F nn      = length nn + 30
            // _n         = length n + 8
            int length;
            if (lowNibble == 0x0f)
            {
                length = data.Next();
                if (length == 0xff)
                {
                    length = data.Next() + data.Next() << 8;
                }
                else
                {
                    length += 30;
                }
            }
            else
            {
                length = lowNibble + 8;
            }
            for (int i = 0; i < length; ++i)
            {
                result.Add(data.Next());
            }
        }

        private static void LZCopy(List<byte> buffer, int runLength, int runOffset)
        {
            // The source and dest may overlap! So we do a dumb copy.
            int fromIndex = buffer.Count - runOffset;
            if (fromIndex < 0)
            {
                throw new Exception("Invalid LZ offset");
            }
            for (int i = 0; i < runLength; ++i)
            {
                buffer.Add(buffer[fromIndex++]);
            }
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

        private static int DecodeSplitPointer(byte[] file, int offsetTable, int tableDelta, int index)
        {
            return file[offsetTable + index] | (file[offsetTable + tableDelta + index] << 8);
        }

        static readonly string lookupLow = "ABCDEFGHIJKLMN PQRSTUVWXYZO123456789";
        static readonly string lookupHigh = "!-?";

        public static string DecodeString(byte[] file, int offset, int limit = 0)
        {
            string result = "";
            bool stopAtInvalid = limit == 0;
            for (int i = 0; stopAtInvalid || i < limit; ++i)
            {
                byte b = file[offset + i];
                if (b < lookupLow.Length)
                {
                    result += lookupLow[b];
                }
                else
                {
                    b -= 0xb4;
                    if (b < lookupHigh.Length)
                    {
                        result += lookupHigh[b];
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
                .Where(c => !lookupLow.Contains(c) && !lookupHigh.Contains(c))
                .Aggregate("", (current, c) => current + c)
                .PadRight(width, ' ')
                .Substring(0, width);
        }

        internal static int TrackTypeDataPageNumber(byte[] file, int trackType)
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
            private int _bitsUsed;
            private int _offset;

            public BitmaskHelper(IList<byte> output)
            {
                _output = output;
            }

            public void PutBit(int bit)
            {
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
            }
        }

        private abstract class Match
        {
            public int Offset { get; set; } // Where in the data it is
            public int Length { get; set; } // How many bytes it emits

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
                bool thisBeforeOther = Offset + Length < other.Offset;
                bool otherBeforeThis = other.Offset + other.Length < Offset;
                return !(thisBeforeOther || otherBeforeThis);
            }

            // Get the encoded version of this match
            public abstract IEnumerable<byte> GetBytes(BitmaskHelper bitmaskHelper);
        }

        private class RLEMatch : Match
        {
            // Create a match from the given offset, or null if there is no acceptable match
            public static Match GetBestMatch(IList<byte> data, int offset)
            {
                int count = GetRLECount(data, offset);
                const int minimum = 2;
                const int maximum = 255 + 17;
                if (count < minimum)
                {
                    return null;
                }
                if (count > maximum)
                {
                    count = maximum;
                }
                return new RLEMatch { Offset = offset, Length = count, };
            }

            public override IEnumerable<byte> GetBytes(BitmaskHelper bitmaskHelper)
            {
                bitmaskHelper.PutBit(1);
                if (Length < 17)
                {
                    // 1n    = repeat last written byte n + 2 times (so range 2..16)
                    yield return (byte)(0x10 | (Length - 2));
                }
                else
                {
                    // _F nn = repeat last written byte nn + 17 times (so range 17..272)
                    yield return 0x1f;
                    yield return (byte)(Length - 17);
                }
            }
        }

        private class IncrementingMatch : Match
        {
            // Create a match from the given offset, or null if there is no acceptable match
            public static Match GetBestMatch(IList<byte> data, int offset)
            {
                int count = GetCountingRun(data, offset);
                const int minimum = 2;
                const int maximum = 255 + 17;
                if (count < minimum)
                {
                    return null;
                }
                if (count > maximum)
                {
                    count = maximum;
                }
                return new IncrementingMatch { Offset = offset, Length = count, };
            }

            public override IEnumerable<byte> GetBytes(BitmaskHelper bitmaskHelper)
            {
                bitmaskHelper.PutBit(1);
                if (Length < 17)
                {
                    // 7n    = repeat last written byte n + 2 times (range 2..16)
                    yield return (byte)(0x70 | (Length - 2));
                }
                else
                {
                    // 7F nn = repeat last written byte nn + 17 times (range 17..272)
                    yield return 0x7f;
                    yield return (byte)(Length - 17);
                }
            }
        }

        private class RawMatch : Match
        {
            public IList<byte> Data { get; set; }

            // No GetBestMatch

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

                // "Encoded" raw
                if (Length < 22)
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
                    yield return (byte)(Length >> 8);
                    yield return (byte)(Length & 0xff);
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
            public int LZOffset { get; set; }

            // Create a match from the given offset, or null if there is no acceptable match
            public static Match GetBestMatch(IList<byte> data, int offset)
            {
                // Different LZ options have different limits:
                //
                // Type     Length      LZOffset
                //          Min    Max       Min            Max
                // Tiny     0+2    3+2  Length+0    Length+0x3f
                // Medium   0+3  255+3       0+2      512+255+2
                // Big      0+4  255+4       0+1  255*256+255+1
                //
                const int minLength = 2;


                LZMatch match = GetLZMatch(data, offset);
                // If length is too short, return
                if (match.Length < minLength)
                {
                    return null;
                }
                // Else make sure it fits one of the options
                // We check the offset
                bool isOk = 
                    (
                        // Tiny
                        match.Length >= 0 + 2 && 
                        match.Length <= 3 + 2 && 
                        match.LZOffset >= match.Length && 
                        match.LZOffset <= match.Length + 0x3f
                    ) || (
                        // Medium
                        match.Length >= 0+3 && 
                        match.Length <= 255+3 && 
                        match.LZOffset >= 0 + 2 && 
                        match.LZOffset <= 512 + 255 + 2
                    ) || (
                        // Big
                        match.Length >= 0 + 4 &&
                        match.Length <= 255 + 4 &&
                        match.LZOffset >= 0 + 1 &&
                        match.LZOffset <= 255 * 256 + 255 + 1
                    );
                if (!isOk)
                {
                    return null;
                }
                return match;
            }

            public override IEnumerable<byte> GetBytes(BitmaskHelper bitMaskHelper)
            {
                bitMaskHelper.PutBit(1);
                if (Length < 6 && (LZOffset - Length - 2) < 0x40)
                {
                    // %1nnooooo = copy n+2 bytes from relative offset -(o+n+2)
                    yield return (byte)(0x80 | ((Length - 2) << 5) | (LZOffset - Length - 2));
                }
                else if (Length < 19 && LZOffset <= 512 + 2 + Length)
                {
                    if (LZOffset <= 255 + 2)
                    {
                        // 2x nn = copy x+3 bytes from relative offset -(nn+2)
                        yield return (byte)(0x20 | (Length - 3));
                        yield return (byte)(LZOffset - 2);
                    }
                    else if (LZOffset <= 255 + 2 + 256)
                    {
                        // 3x nn = copy x+3 bytes from relative offset -(nn+2+256)
                        yield return (byte)(0x30 | (Length - 3));
                        yield return (byte)(LZOffset - 2 - 256);
                    }
                    else if (LZOffset <= 255 + 2 + 512)
                    {
                        // 4x nn = copy x+3 bytes from relative offset -(nn+2+512)
                        yield return (byte)(0x40 | (Length - 3));
                        yield return (byte)(LZOffset - 2 - 512);
                    }
                    throw new Exception("Invalid LZMatch");
                }
                else
                {
                    if (LZOffset > 0xe * 256 + 255 + 1)
                    {
                        // 5f hh oo cc = copy c+4 bytes from relative offset -(h*256+o+1)
                        yield return 0x5f;
                        yield return (byte)((LZOffset - 1) >> 8);
                        yield return (byte)((LZOffset - 1) & 0xff);
                        yield return (byte)(Length - 4);
                    }
                    else
                    {
                        // 5x oo cc    = copy c+4 bytes from relative offset -(x*256+o+1)
                        yield return (byte)(0x50 | ((LZOffset - 1) >> 8));
                        yield return (byte)((LZOffset - 1) & 0xff);
                        yield return (byte)(Length - 4);
                    }
                }

            }
        }

        private class ReverseLZMatch : LZMatch
        {
            public override IEnumerable<byte> GetBytes(BitmaskHelper bitMaskHelper)
            {
                // 6x oo = copy x+3 bytes from oo+1 bytes earlier in the output stream, going backwards
                yield return (byte)(0x60 | (Length - 3));
                yield return (byte)(LZOffset - 1);
            }
        }

        public static IList<byte> Compress(IList<byte> data)
        {
            // We create a list of all the compressible parts in the data
            // There may be more than one starting at the same offset
            List<Match> matches = new List<Match>();

            // Look for compressible chunks in the data. Prefer ones with long lengths first.
            for (int i = 0; i < data.Count; ++i)
            {
                int runLength = GetRLECount(data, i);
                if (runLength > 1) // Should be higher?
                {
                    matches.Add(new RLEMatch { Offset = i, Length = runLength, });
                }

                runLength = GetCountingRun(data, i);
                if (runLength > 1) // Should be higher?
                {
                    matches.Add(new IncrementingMatch { Offset = i, Length = runLength, });
                }

                LZMatch lzMatch = GetLZMatch(data, i);
                if (lzMatch.Length > 1) // Should be higher?
                {
                    matches.Add(new LZMatch { Offset = i, Length = lzMatch.Length, LZOffset = i - lzMatch.Offset, });
                }

                lzMatch = GetReverseLZMatch(data, i);
                if (lzMatch.Length > 1) // Should be higher?
                {
                    matches.Add(new ReverseLZMatch { Offset = i, Length = lzMatch.Length, LZOffset = i - lzMatch.Offset, });
                }
            }

            List<Match> compressedChunks = new List<Match>();
            while (matches.Count > 0)
            {
                // Then pick the longest
                Match bestMatch = matches.OrderByDescending(x => x.Length).First();
                // Add it to our list
                compressedChunks.Add(bestMatch);

                // Then we want to remove any matches that overlapped it
                int minOffset = bestMatch.Offset - 1;
                int maxOffset = bestMatch.Offset + bestMatch.Length;
                matches.RemoveAll(x => !x.Overlaps(bestMatch));

                // And repeat
            }

            // Then we loop over the chunls and insert "raw" chunks in the gaps
            List<Match> allChunks = new List<Match>();
            int offset = 0;
            foreach (Match compressedChunk in compressedChunks)
            {
                int chunkOffset = compressedChunk.Offset;
                if (chunkOffset > offset)
                {
                    // Emit a raw chunk
                    allChunks.Add(new RawMatch { Data = data, Offset = offset, Length = chunkOffset - offset, });
                }
                allChunks.Add(compressedChunk);
                offset = compressedChunk.Offset + compressedChunk.Length;
            }
            // Add a final raw chunk if needed
            if (offset < data.Count)
            {
                allChunks.Add(new RawMatch { Data = data, Offset = offset, Length = data.Count - offset, });
            }

            // Then emit them all
            List<byte> result = new List<byte>();
            BitmaskHelper bitmaskHelper = new BitmaskHelper(result);
            foreach (Match chunk in allChunks)
            {
                result.AddRange(chunk.GetBytes(bitmaskHelper));
            }

            return result;
        }

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
            return offset - start - 1;
        }

        private static LZMatch GetReverseLZMatch(IList<byte> data, int start)
        {
            int bestLength = 0;
            int bestOffset = 0;
            // We do a dumb walk backwards through the data
            for (int i = start - 1; i > 0; --i)
            {
                // Check for a match
                int matchLength = 0;
                for (; i - matchLength >= 0; ++matchLength)
                {
                    byte wanted = data[start + matchLength];
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
            return new LZMatch { Length = bestLength, Offset = bestOffset, };
        }

        private static LZMatch GetLZMatch(IList<byte> data, int start)
        {
            int bestLength = 0;
            int bestOffset = 0;
            // We do a dumb walk forwards through the data
            for (int i = 0; i < start; ++i)
            {
                // Check for a match
                int matchLength = 0;
                for (; i + matchLength < data.Count; ++matchLength)
                {
                    byte wanted = data[start + matchLength];
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
            return new LZMatch { Length = bestLength, Offset = bestOffset, };
        }

        private static int GetRLECount(IList<byte> data, int start)
        {
            byte b = data[start];
            for (int i = start; i < data.Count; ++i)
            {
                if (data[i] != b)
                {
                    return i - start;
                }
            }
            return 1;
        }
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
    }
}
