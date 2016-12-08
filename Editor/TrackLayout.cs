using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Drawing2D;

namespace MicroMachinesEditor
{
    public class TrackLayout
    {
        private byte[,] _metaTileIndices = new byte[32,32];
        private byte[,] _positions = new byte[32,32];

        public TrackLayout(IReadOnlyList<byte> metaTileData, IReadOnlyList<byte> positionData)
        {
            for (int y = 0; y < 32; ++y)
            {
                for (int x = 0; x < 32; ++x)
                {
                    _metaTileIndices[x,y] = metaTileData[x + y * 32];
                    _positions[x,y] = positionData[x + y * 32];
                }
            }
        }

        public Bitmap Render(IList<MetaTile> metaTiles)
        {
            // We always render the whole 32x32 range, although the actual level is a subset of it
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
                    int metaTileIndex = _metaTileIndices[x,y] & 0x3f; // Other bits do something
                    Rectangle tileRect = new Rectangle(x*96, y*96, 96, 96);
                    Bitmap metaTile = metaTiles[metaTileIndex].Bitmap;
                    lock (metaTile)
                    {
                        g.DrawImageUnscaled(metaTile, tileRect);
                    }

                    byte trackPosition = _positions[x,y];
                    if (trackPosition != 0)
                    {
                        g.DrawRectangle(SystemPens.ActiveCaption, tileRect);
                        var s = trackPosition.ToString();
                        DrawTextInBox(g, tileRect, s, font, 1);
                    }

                    int otherBits = _metaTileIndices[x,y] >> 6;
                    if (otherBits != 0)
                    {
                        var s = otherBits.ToString();
                        DrawTextInBox(g, tileRect, s, font, 2);
                    }
                }
            }

            font.Dispose();
            g.Dispose();

            return result;
        }

        private void DrawTextInBox(Graphics g, Rectangle outerRect, string s, Font font, int corner)
        {
            SizeF textSize = g.MeasureString(s, font);
            RectangleF rect;
            switch (corner)
            {
                default:
                case 1: // Top left
                    rect = new RectangleF(outerRect.Left, outerRect.Top, textSize.Width, textSize.Height);
                    break;
                case 2: // Top right
                    rect = new RectangleF(outerRect.Right - textSize.Width, outerRect.Top, textSize.Width, textSize.Height);
                    break;
                case 3: // Bottom right
                    rect = new RectangleF(outerRect.Right - textSize.Width, outerRect.Bottom - textSize.Height, textSize.Width, textSize.Height);
                    break;
                case 4: // Bottom left
                    rect = new RectangleF(outerRect.Left, outerRect.Bottom - textSize.Height, textSize.Width, textSize.Height);
                    break;
            }
            g.FillRectangle(SystemBrushes.ActiveCaption, rect);
            g.DrawString(s, font, SystemBrushes.ActiveCaptionText, rect);
        }

        internal int TileIndexAt(int x, int y)
        {
            if (x > 31 || x < 0 || y > 31 || y < 0)
            {
                return -1;
            }
            return _metaTileIndices[x, y] & 0x3f;
        }

        internal int FlagsAt(int x, int y)
        {
            if (x > 31 || x < 0 || y > 31 || y < 0)
            {
                return -1;
            }
            return _metaTileIndices[x, y] >> 6;
        }

        internal void Rotate(int dx, int dy)
        {
            Rotate(ref _metaTileIndices, dx, dy);
            Rotate(ref _positions, dx, dy);
        }

        private void Rotate(ref byte[,] array, int dx, int dy)
        {
            // I'll just copy into a new one...
            byte[,] result = new byte[32,32];
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
                    _positions[x, y] = 0;
                }
            }
        }

        internal void SetTileIndex(int x, int y, int metaTileIndex)
        {
            if (x > 31 || x < 0 || y > 31 || y < 0 || metaTileIndex < 0 || metaTileIndex > 0x3f)
            {
                return;
            }
            _metaTileIndices[x, y] = (byte)((_metaTileIndices[x, y] & 0xc0) | (metaTileIndex & 0x3f));
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
