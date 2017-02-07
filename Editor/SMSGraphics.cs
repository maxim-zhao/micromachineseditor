using System.Collections.Generic;
using System.Drawing;

namespace MicroMachinesEditor
{
    public static class SMSGraphics
    {
        public static IList<Color> ReadPalette(byte[] data, int offset, int count)
        {
            var result = new List<Color>(count);
            for (int i = 0; i < 32; ++i)
            {
                byte b = data[offset + i];
                Color color = PaletteEntryToColor(b);
                result.Add(color);
            }
            return result;
        }

        public static Color PaletteEntryToColor(byte b)
        {
            // Pull out the components
            int red = (b >> 0) & 0x03;
            int green = (b >> 2) & 0x03;
            int blue = (b >> 4) & 0x03;
            // Extend them to full-range
            red |= red << 2; red |= red << 4;
            green |= green << 2; green |= green << 4;
            blue |= blue << 2; blue |= blue << 4;
            // Convert to a colour
            return Color.FromArgb(red, green, blue);
        }

        public static IList<Tile> ReadTiles(byte[] data, int offset, int byteCount, IList<Color> palette, int bitDepth = 4)
        {
            // Build collection of tiles
            int bytesPerTile = 8*bitDepth;
            int numTiles = byteCount / bytesPerTile;
            var result = new List<Tile>(numTiles);
            for (int i = 0; i < numTiles; ++i)
            {
                var tile = new Tile(data, offset, palette, bitDepth);
                offset += bytesPerTile;
                result.Add(tile);
            }
            return result;
        }

        public class Tile
        {
            public Bitmap Bitmap { get; private set; }

            public Tile(IList<byte> data, int offset, IList<Color> palette, int bitDepth)
            {
                Bitmap = new Bitmap(8, 8);

                // Each bitDepth bytes represents one row
                for (int y = 0; y < 8; ++y)
                {
                    byte byte0 = data[offset + 0];
                    byte byte1 = bitDepth > 1 ? data[offset + 1] : (byte)0;
                    byte byte2 = bitDepth > 2 ? data[offset + 2] : (byte)0;
                    byte byte3 = bitDepth > 3 ? data[offset + 3] : (byte)0;

                    // Each pixel in the row is given by a bit from each byte, left to right,
                    // least to most significant
                    for (int column = 0; column < 8; ++column)
                    {
                        // Column 0 is bit 7, etc
                        int shift = 7 - column;
                        int bit1 = (byte0 >> shift) & 1;
                        int bit2 = (byte1 >> shift) & 1;
                        int bit3 = (byte2 >> shift) & 1;
                        int bit4 = (byte3 >> shift) & 1;
                        int paletteIndex =
                            (bit1 << 0) |
                            (bit2 << 1) |
                            (bit3 << 2) |
                            (bit4 << 3);
                        Color color = palette[paletteIndex];
                        Bitmap.SetPixel(column, y, color);
                    }

                    offset += bitDepth;
                }
            }
        }
    }
}
