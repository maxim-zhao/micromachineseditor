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

        #endregion

        #region Properties

        public Bitmap Bitmap { get; private set; }

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
        public MetaTile(IList<byte> tileIndexData, int tileIndexDataOffset, IList<SMSGraphics.Tile> tiles, IList<byte> wallData, int wallDataOffset, IList<byte> data2, int offset2, IList<byte> behaviourLookup)
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
                
                // Then we copy over the data2
                for (int y = 0; y < 6; ++y)
                {
                    for (int x = 0; x < 6; ++x)
                    {
                        int offset = x + y*6 + offset2;
                        int data2Value = offset >= data2.Count ? 0 : data2[offset];
                        int behaviourIndex = data2Value >> 4;
                        int behaviour = behaviourLookup[behaviourIndex];
                        _behaviour[x, y] = behaviour;

                        _unknown[x, y] = data2Value & 0xf;
/*
                        if (behaviour > 0)
                        {
                            g.DrawString(behaviour.ToString("x"), SystemFonts.DefaultFont, Brushes.Fuchsia, x * 16, y * 16);
                            g.DrawRectangle(Pens.Fuchsia, x * 16, y * 16, 15, 15);
                        }
                        */
                        int lowNibble = data2Value & 0xf;
                        if (lowNibble > 0)
                        {
                            g.DrawString(lowNibble.ToString("x"), SystemFonts.DefaultFont, Brushes.Blue, x * 16, y * 16);
                            g.DrawRectangle(Pens.Blue, x * 16, y * 16, 15, 15);
                        }
 
                    }
                }
            }
        }
    }
}
