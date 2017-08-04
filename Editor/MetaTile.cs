using System.Collections.Generic;
using System.Drawing;

namespace MicroMachinesEditor
{
    // Holds info on a metatile. This is:
    // - a 12x12 array of tile graphics
    // - a 12x12 array of wall data (solidity)
    // - a 6x6 array of "behaviour" 
    // - a 6x6 array of "unknown"
    // It renders it to a bitmap at construction time.
    public class MetaTile
    {
        #region Constants

        private const int TilesPerSide = 12;
        private const int PixelsPerTile = 8;
        private const int PixelsPerSide = TilesPerSide*PixelsPerTile; // 96
        private const int WallDataSizeInBytes = TilesPerSide*TilesPerSide/8; // 18 bytes to hold 12*12 bits

        #endregion

        #region Fields

        private readonly SMSGraphics.Tile[,] _tiles = new SMSGraphics.Tile[TilesPerSide, TilesPerSide]; // Not used currently
        private readonly bool[,] _walls = new bool[TilesPerSide, TilesPerSide];
        private readonly int[,] _behaviour = new int[6, 6];
        private readonly int[,] _unknown = new int[6, 6];
        private readonly Brush _behaviourOverlayBrush = new SolidBrush(Color.FromArgb(128, Color.HotPink));

        #endregion

        #region Properties

        public Bitmap Bitmap { get; }

        #endregion

        /// <summary>
        /// Constructs a MetaTile object, including rendering it to a bitmap
        /// </summary>
        /// <param name="tileIndexData">Buffer holding tile index metadata (one byte per tile, row-major order)</param>
        /// <param name="tileIndexDataOffset">Offset of tile index data in tileIndexData</param>
        /// <param name="tiles">Tile objects to use</param>
        /// <param name="wallData">Buffer holding wall data</param>
        /// <param name="wallDataOffset">Offset of wall data in wallData</param>
        /// <param name="data2">Buffer holding somewhat unknown </param>
        /// <param name="offset2"></param>
        /// <param name="behaviourLookup"></param>
        /// <param name="trackType"></param>
        public MetaTile(IReadOnlyList<byte> tileIndexData, int tileIndexDataOffset, IReadOnlyList<SMSGraphics.Tile> tiles, IReadOnlyList<byte> wallData, int wallDataOffset, IList<byte> data2, int offset2, IList<byte> behaviourLookup, TrackTypeData.TrackType trackType)
        {
            // We build up our image
            Bitmap = new Bitmap(PixelsPerSide, PixelsPerSide);
            using (var g = Graphics.FromImage(Bitmap))
            {
                // Draw tiles
                for (int y = 0; y < TilesPerSide; ++y)
                {
                    for (int x = 0; x < TilesPerSide; ++x)
                    {
                        int tileIndex = tileIndexData[tileIndexDataOffset + x + y*TilesPerSide];
                        _tiles[x, y] = tiles[tileIndex];

                        g.DrawImageUnscaled(tiles[tileIndex].Bitmap, x*8, y*8);

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
                    }
                }
                
                // Then we copy over the behaviour data
                for (int y = 0; y < 6; ++y)
                {
                    for (int x = 0; x < 6; ++x)
                    {
                        int offset = x + y*6 + offset2;
                        int data2Value = offset >= data2.Count ? 0 : data2[offset];
                        int behaviourIndex = (data2Value >> 4) & (trackType == TrackTypeData.TrackType.Powerboats ? 0xe : 0xf);
                        int behaviour = behaviourLookup[behaviourIndex];
                        _behaviour[x, y] = behaviour;

                        _unknown[x, y] = data2Value & (trackType == TrackTypeData.TrackType.Powerboats ? 0x1f : 0x0f);

//#if DRAW_BEHAVIOUR

                        if (behaviour > 0)
                        {
                            g.FillRectangle(_behaviourOverlayBrush, x * 16, y * 16, 15, 15);
                            g.DrawString($"{behaviour:x}", SystemFonts.DefaultFont, Brushes.White, x * 16, y * 16);
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
                            // c = ?? (place mat)
                            // d = ?? (place mat, bumps?)
                            // e = deep water/die (ruff trux)
                            // f = ?? (not used in the game, code exists)
                            // 12 = deep water/die (turbo wheels)
                            // 13 = pool cue (no effect?)
                        }

//#endif

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
                        /*                            if ((lowNibble & 0x8) != 0)
                                                    {
                                                        g.DrawString("1", SystemFonts.DefaultFont, Brushes.Red, x*16, y*16);
                                                    }
                                                    else
                                                    {
                                                        g.DrawString("0", SystemFonts.DefaultFont, Brushes.Red, x * 16, y * 16);
                                                    }*/
                        //}
                    }
                }
            }
        }
    }
}
