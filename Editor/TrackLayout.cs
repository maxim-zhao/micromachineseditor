using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Drawing2D;

namespace MicroMachinesEditor
{
    /// <summary>
    /// Holds data related to layout for a track
    /// * The metatile layout
    /// * The per-metatile AI data
    /// * The race positions layout
    /// </summary>
    public class TrackLayout
    {
        // The metatile at each metatile
        private int[,] _metaTileIndices = new int[32, 32];
        // Extra data for each metatile (TODO: make it better typed)
        private int[,] _metaTileHighBits = new int[32, 32];
        // The track "progress" value, or 0, for each metatile
        private int[,] _positions = new int[32,32];

        public TrackLayout(IReadOnlyList<byte> metaTileData, IReadOnlyList<byte> positionData)
        {
            for (int y = 0; y < 32; ++y)
            {
                for (int x = 0; x < 32; ++x)
                {
                    // Easy ones
                    _metaTileIndices[x, y] = (byte) (metaTileData[x + y * 32] & 0x3f);
                    _positions[x, y] = positionData[x + y * 32];

                    // Harder
                    _metaTileHighBits[x, y] = (byte)(metaTileData[x + y * 32] >> 6);
                }
            }
        }

        public Bitmap Render(IList<MetaTile> metaTiles)
        {
            // We always render the whole 32x32 range, although the actual level is a subset of it
            // There is often junk data out of bounds in the game data, it would save space to blank it out
            // TODO this is only used for thumbnails, should we fall back to TrackEditor to do this work?
            int dimensions = 32*96;
            Bitmap result = new Bitmap(dimensions, dimensions);
            Graphics g = Graphics.FromImage(result);

            g.InterpolationMode = InterpolationMode.NearestNeighbor;
            g.PixelOffsetMode = PixelOffsetMode.HighQuality;

            Font font = new Font("Tahoma", 8);

            for (int y = 0; y < 32; ++y)
            {
                for (int x = 0; x < 32; ++x)
                {
                    int metaTileIndex = _metaTileIndices[x, y];
                    Rectangle tileRect = new Rectangle(x*96, y*96, 96, 96);
                    Bitmap metaTile = metaTiles[metaTileIndex].Bitmap;
                    lock (metaTile)
                    {
                        g.DrawImageUnscaled(metaTile, tileRect);
                    }
                }
            }

            font.Dispose();
            g.Dispose();

            return result;
        }

        internal int TileIndexAt(Point p)
        {
            if (p.X > 31 || p.X < 0 || p.Y > 31 || p.Y < 0)
            {
                return -1;
            }
            return _metaTileIndices[p.X, p.Y];
        }

        internal int FlagsAt(int x, int y)
        {
            if (x > 31 || x < 0 || y > 31 || y < 0)
            {
                return -1;
            }
            return _metaTileHighBits[x, y];
        }

        internal void Rotate(int dx, int dy)
        {
            Rotate(ref _metaTileIndices, dx, dy);
            Rotate(ref _metaTileHighBits, dx, dy);
            Rotate(ref _positions, dx, dy);
        }

        private static void Rotate(ref int[,] array, int dx, int dy)
        {
            // I'll just copy into a new one...
            var result = new int[32,32];
            for (int y = 0; y < 32; ++y)
            {
                for (int x = 0; x < 32; ++x)
                {
                    int newX = (x + dx + 32) % 32;
                    int newY = (y + dy + 32) % 32;
                    result[newX, newY] = array[x, y];
                }
            }
            array = result;
        }

        internal void Blank(int metatileIndex)
        {
            for (int y = 0; y < 32; ++y)
            {
                for (int x = 0; x < 32; ++x)
                {
                    _metaTileIndices[x, y] = (byte)metatileIndex;
                    _metaTileHighBits[x, y] = 0;
                    _positions[x, y] = 0;
                }
            }
        }

        internal void SetTileIndex(Point p, int metaTileIndex)
        {
            if (p.X > 31 || p.X < 0 || p.Y > 31 || p.Y < 0 || metaTileIndex < 0 || metaTileIndex > 0x3f)
            {
                return;
            }
            _metaTileIndices[p.Y, p.Y] = (byte)(metaTileIndex & 0x3f);
        }

        internal int TrackPositionAt(int x, int y)
        {
            if (x > 31 || x < 0 || y > 31 || y < 0)
            {
                return -1;
            }
            return _positions[x, y];
        }
    }
}
