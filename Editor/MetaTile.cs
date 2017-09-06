using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Drawing2D;

namespace MicroMachinesEditor
{
    // Holds info on a metatile. This is:
    // * a 12x12 array of tile graphics
    // * a 12x12 array of wall data (solidity)
    // * a 6x6 array of "behaviour" 
    // * a 6x6 array of "unknown"
    // It renders it to a bitmap at construction time.
    public class MetaTile
    {
        #region Constants

        private const int TilesPerSide = 12;
        private const int PixelsPerTile = 8;
        private const int PixelsPerSide = TilesPerSide * PixelsPerTile; // 96
        private const int WallDataSizeInBytes = TilesPerSide * TilesPerSide / 8; // 18 bytes to hold 12*12 bits

        #endregion

        #region Fields

        private readonly SMSGraphics.Tile[,] _tiles = new SMSGraphics.Tile[TilesPerSide, TilesPerSide]; // Not used currently

        private readonly bool[,] _walls = new bool[TilesPerSide, TilesPerSide];
        private readonly int[,] _behaviour = new int[6, 6]; // TODO make into an enum?
        private readonly int[,] _unknown = new int[6, 6];

        // Stuff for drawing, should dispose properly
        private readonly Brush _behaviourOverlayBrush = new SolidBrush(Color.FromArgb(128, Color.HotPink));
        private readonly List<Pen> _pens = new List<Pen>
        {
            new Pen(Color.Black, 1),
            new Pen(Color.Black, 2),
            new Pen(Color.Black, 3)
        };

        #endregion

        #region Properties

        public Bitmap Bitmap { get; }

        public class UnknownData
        {
            public UnknownData(byte data)
            {
                RawValue = data;
                LookupIndex = (data >> 5) & 0x3;
                HighBit = (data >> 7) == 1;
                Bits234 = (data >> 2) & 0x7;
                // Low two bits are not used?
            }

            public int Bits234 { get; }

            public bool HighBit { get; }

            public int LookupIndex { get; }

            public byte RawValue { get; }
        }

        public UnknownData UnknownDataValue { get; }

        #endregion

        /// <summary>
        /// Constructs a MetaTile object, including rendering it to a bitmap
        /// </summary>
        /// <param name="tileIndexData">Buffer holding tile index metadata (one byte per tile, row-major order)</param>
        /// <param name="tileIndexDataOffset">Offset of tile index data in tileIndexData</param>
        /// <param name="tiles">Tile objects to use</param>
        /// <param name="wallData">Buffer holding wall data</param>
        /// <param name="wallDataOffset">Offset of wall data in wallData</param>
        /// <param name="data2">Buffer holding behaviour data</param>
        /// <param name="offset2"></param>
        /// <param name="behaviourLookup"></param>
        /// <param name="trackType"></param>
        /// <param name="bubblePushDirection">The direction from bubble push data</param>
        /// <param name="unknownData"></param>
        public MetaTile(IReadOnlyList<byte> tileIndexData, int tileIndexDataOffset, IReadOnlyList<SMSGraphics.Tile> tiles, IReadOnlyList<byte> wallData, int wallDataOffset, IList<byte> data2, int offset2, IList<byte> behaviourLookup, TrackTypeData.TrackType trackType, Direction bubblePushDirection, byte unknownData)
        {
            // We build up our image
            Bitmap = new Bitmap(PixelsPerSide, PixelsPerSide);
            UnknownDataValue = new UnknownData(unknownData);
            using (var g = Graphics.FromImage(Bitmap))
            {
                g.SmoothingMode = SmoothingMode.HighQuality;
                // Draw tiles
                for (int y = 0; y < TilesPerSide; ++y)
                {
                    for (int x = 0; x < TilesPerSide; ++x)
                    {
                        int tileIndex = tileIndexData[tileIndexDataOffset + x + y*TilesPerSide];
                        _tiles[x, y] = tiles[tileIndex];

                        g.DrawImageUnscaled(tiles[tileIndex].Bitmap, x*8, y*8);

#if DRAW_WALLS
                        // We also extract the wall solidity data
                        int tileNumber = y*TilesPerSide + x;
                        int wallDataBitNumber = tileNumber % 8;
                        int wallDataByteNumber = tileNumber / 8;
                        if (wallDataOffset + wallDataByteNumber < wallData.Count)
                        {
                            byte wallDataByte = wallData[wallDataOffset + wallDataByteNumber];
                            bool isWall = ((wallDataByte >> (7 - wallDataBitNumber)) & 1) == 1;
                            _walls[x, y] = isWall;

                            if (isWall)
                            {
                                g.DrawRectangle(Pens.Black, x*8, y*8, 7, 7);
                            }
                        }
#endif
                    }
                }
                
                // Then we copy over the behaviour data
                for (int y = 0; y < 6; ++y)
                {
                    for (int x = 0; x < 6; ++x)
                    {
                        int offset = x + y*6 + offset2;
                        int behaviourDataByte = offset >= data2.Count ? 0 : data2[offset];

                        // The low nibble is an index into some lookups
                        var lookupIndex = behaviourDataByte & 0xf;
                        // The place it looks up depends on some data in the layout, so we just store the index
                        _unknown[x, y] = lookupIndex;

                        // The high nibble (ignoring the low bit for Powerboats?) is an object type index, which maps to a behaviour
                        int behaviourIndex = (behaviourDataByte >> 4) & (trackType == TrackTypeData.TrackType.Powerboats ? 0xe : 0xf);
                        int behaviour = behaviourLookup[behaviourIndex];
                        _behaviour[x, y] = behaviour;

#if DRAW_BEHAVIOUR
                        if (behaviour > 0)
                        {
                            g.FillRectangle(_behaviourOverlayBrush, x * 16, y * 16, 15, 15);
                            g.DrawString($"{behaviourIndex:x}", SystemFonts.DefaultFont, Brushes.White, x * 16, y * 16);
                            // Values seem to be:
                            // 0 = normal
                            // 1 = fall to floor/die
                            // 2 = chalk/dust
                            // 3 = bump on exit, enter from 7
                            // 4 = big jump (folders, enter only from 7?)
                            // 5 = skid (milk, ink, oil, cards)
                            // 6 = bump (cereal, bubbles, soap, top of book, ruler, nails, lego, pencils)
                            // 7 = jump entry
                            // 8 = sticky (orange juice, glue)
                            // 9 = pool table hole
                            // a = death? (pool table edges)
                            // b = raised
                            // c = raised entry (ramps)
                            // d = bump on entry (place mat, certain bumps)
                            // e = deep water/die (ruff trux)
                            // f = immediate death (not used in the game, code exists)
                            // 12 = deep water/die (turbo wheels)
                            // 13 = pool cue (barrier, could use wall?)
                        }
#endif
                        if (trackType == TrackTypeData.TrackType.Powerboats && bubblePushDirection != Direction.Invalid)
                        {
                            // Draw "push" arrows
                            // Strength is in the middle two bits
                            // Direction is common to the tile
                            var strength = (behaviourDataByte >> 3) & 0x3;
                            if (strength != 0)
                            {
                                // We use the strength for the line width
                                var pen = _pens[strength - 1];

                                var transform = g.Transform;
                                // Transform to our arrow position
                                g.TranslateTransform(x * 16 + 8, y * 16 + 8);
                                g.RotateTransform((int) bubblePushDirection * 360.0f/16);
                                // Draw an arrow upwards in the transformed context
                                g.DrawLine(pen, 0, -8, 0, 7);
                                g.DrawLine(pen, -4, 0, 0, -8);
                                g.DrawLine(pen, 4, 0, 0, -8);
                                // Restore the transform
                                g.Transform = transform;
                            }
                        }

#if DRAW_BEHAVIOUR_LOW
                        // Low 4 bits (5 for powerboats)
                        int lowNibble = data2Value & (trackType == TrackTypeData.TrackType.Powerboats ? 0x1f : 0xf);
                        if (lowNibble > -1)
                        {
//                            g.DrawString(lowNibble.ToString("x"), SystemFonts.DefaultFont, Brushes.Yellow, x * 16, y * 16);
                            //g.DrawRectangle(Pens.Blue, x * 16, y * 16, 15, 15);
                            switch (lowNibble & 0x3)
                            {
                                case 0:
                                    // -
                                    g.DrawLine(Pens.Blue, x * 16, y * 16 + 8, x * 16 + 16, y * 16 + 8);
                                    break;
                                case 1:
                                    // /
                                    g.DrawLine(Pens.Blue, x * 16, y * 16, x * 16 + 16, y * 16 + 16);
                                    break;
                                case 2:
                                    // |
                                    g.DrawLine(Pens.Blue, x * 16 + 8, y * 16, x * 16 + 8, y * 16 + 16);
                                    break;
                                case 3:
                                    // \
                                    g.DrawLine(Pens.Blue, x * 16, y * 16 + 16, x * 16 + 16, y * 16);
                                    break;
                            }
                        }
#endif
                    }
                }
                /*
                using (var f = new Font(FontFamily.GenericSansSerif, 16))
                {
                    if ((unknownData & 0x80) != 0)
                    {
                        g.FillRectangle(_behaviourOverlayBrush, 0,0,96,96);
                    }
                    unknownData &= 0x7f;
                    g.DrawString(unknownData.ToString("X2"), f, Brushes.Black, 4, 4);
                    g.DrawString(unknownData.ToString("X2"), f, Brushes.White, 3, 3);
                }
                */
            }
        }

        public int behaviourLowAt(int x, int y)
        {
            return _unknown[x, y];
        }

        public enum Direction
        {
            North,
            NorthNorthEast,
            NorthEast,
            EastNorthEast,
            East,
            EastSouthEast,
            SouthEast,
            SouthSouthEast,
            South,
            SouthSouthWest,
            SouthWest,
            WestSouthWest,
            West,
            WestNorthWest,
            NorthWest,
            NorthNorthWest,
            Invalid = 0xff
        }
    }
}
