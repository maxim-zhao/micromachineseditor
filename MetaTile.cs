using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Text;

namespace MicroMachinesEditor
{
    public class MetaTile
    {
        // Holds info on a metatile. This is a 12x12 array of tiles.
        SMSGraphics.Tile[,] tiles = new SMSGraphics.Tile[12, 12]; // Not used currently
        bool[,] walls = new bool[12,12];
        int[,] behaviour = new int[6, 6];
        int[,] unknown = new int[6, 6];

        public Bitmap Bitmap { get; private set; }

        public MetaTile(IList<byte> dataTiles, int offsetTiles, IList<SMSGraphics.Tile> tiles, IList<byte> wallData, int offsetWallData, IList<byte> data2, int offset2, IList<byte> behaviourLookup)
        {
            // We build up our image
            Bitmap = new Bitmap(96, 96);
            Graphics g = Graphics.FromImage(Bitmap);
            for (int y = 0; y < 12; ++y)
            {
                for (int x = 0; x < 12; ++x)
                {
                    int tileIndex = dataTiles[offsetTiles + x + y * 12];
                    this.tiles[x, y] = tiles[tileIndex];

                    g.DrawImageUnscaled(tiles[tileIndex].Bitmap, x * 8, y * 8);
                }
            }

            // We also expand the bit-oriented wall data to a more wasteful 2D array of bools
            for (int i = 0; i < 18; ++i)
            {
                int wallDataByte;
                if (offsetWallData >= wallData.Count)
                {
                    // Ran out of data
                    // The data is always the same between the two tables
                    wallDataByte = 0;
                }
                else
                {
                    wallDataByte = wallData[offsetWallData];
                }

                for (int j = 0; j < 8; ++j)
                {
                    int bitIndex = i * 8 + j;
                    int x = bitIndex % 12;
                    int y = bitIndex / 12;
                    int shift = 7 - j;
                    bool isWall = ((wallDataByte >> shift) & 1) == 1;
                    this.walls[x, y] = isWall;

                    // Draw it onto the metatile
                    if (isWall)
                    {
                        g.DrawRectangle(Pens.Black, x * 8, y * 8, 7, 7);
                    }
                }

                ++offsetWallData;
            }

            // Then we copy over the data2
            for (int y = 0; y < 6; ++y)
            {
                for (int x = 0; x < 6; ++x)
                {
                    int offset = x + y * 6 + offset2;
                    byte data2Value;
                    if (offset >= data2.Count)
                    {
                        data2Value = 0;
                    }
                    else
                    {
                        data2Value = data2[offset];
                    }
                    int behaviourIndex = data2Value >> 4;
                    int behaviour = behaviourLookup[behaviourIndex];
                    this.behaviour[x, y] = behaviour;

                    this.unknown[x, y] = data2Value & 0xf;
                    /*
                    if (behaviour > 0)
                    {
                        g.DrawString(behaviour.ToString("x"), SystemFonts.DefaultFont, Brushes.Fuchsia, x * 16, y * 16);
                        g.DrawRectangle(Pens.Fuchsia, x * 16, y * 16, 15, 15);
                    }
                    /*
                    int lowNibble = data2Value & 0xf;
                    if (lowNibble > 0)
                    {
                        g.DrawString(lowNibble.ToString("x"), SystemFonts.DefaultFont, Brushes.Blue, x * 16, y * 16);
                        g.DrawRectangle(Pens.Blue, x * 16, y * 16, 15, 15);
                    }
 */
                }
            }
        }

        public bool IsWallAt(int x, int y)
        {
            if (x < 0 || x >= 12 | y < 0 || y >= 12)
            {
                return false;
            }
            return this.walls[x, y];
        }
    }
}
