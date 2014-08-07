﻿using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Text;

namespace MicroMachinesEditor
{
    public class TrackLayout
    {
        private byte[,] metaTileIndices = new byte[32,32];
        private byte[,] positions = new byte[32,32];

        public TrackLayout(List<byte> metaTileData, List<byte> positionData)
        {
            for (int y = 0; y < 32; ++y)
            {
                for (int x = 0; x < 32; ++x)
                {
                    metaTileIndices[x,y] = metaTileData[x + y * 32];
                    positions[x,y] = positionData[x + y * 32];
                }
            }
        }

        public Bitmap render(IList<MetaTile> metaTiles)
        {
            // We always render the whole 32x32 range, although the actual level is a subset of it
            int dimensions = 32*96;
            Bitmap result = new Bitmap(dimensions, dimensions);
            Graphics g = Graphics.FromImage(result);

            g.InterpolationMode = System.Drawing.Drawing2D.InterpolationMode.NearestNeighbor;
            g.PixelOffsetMode = System.Drawing.Drawing2D.PixelOffsetMode.HighQuality;

            Font font = new Font("Tahoma", 8);

            int index = 0;
            for (int y = 0; y < 32; ++y)
            {
                for (int x = 0; x < 32; ++x)
                {
                    int metaTileIndex = metaTileIndices[x,y] & 0x3f; // Other bits do something
                    Rectangle tileRect = new Rectangle(x*96, y*96, 96, 96);
                    Bitmap metaTile = metaTiles[metaTileIndex].Bitmap;
                    lock (metaTile)
                    {
                        g.DrawImageUnscaled(metaTile, tileRect);
                    }

                    byte trackPosition = positions[x,y];
                    if (trackPosition != 0)
                    {
                        g.DrawRectangle(SystemPens.ActiveCaption, tileRect);
                        String s = trackPosition.ToString();
                        DrawTextInBox(g, tileRect, s, font, 1);
                    }

                    int otherBits = metaTileIndices[x,y] >> 6;
                    if (otherBits != 0)
                    {
                        String s = otherBits.ToString();
                        DrawTextInBox(g, tileRect, s, font, 2);
                    }

                    ++index;
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
            return metaTileIndices[x, y] & 0x3f;
        }

        internal int FlagsAt(int x, int y)
        {
            if (x > 31 || x < 0 || y > 31 || y < 0)
            {
                return -1;
            }
            return metaTileIndices[x, y] >> 6;
        }

        internal void Rotate(int dx, int dy)
        {
            Rotate(ref this.metaTileIndices, dx, dy);
            Rotate(ref this.positions, dx, dy);
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
                    this.metaTileIndices[x, y] = (byte)metatileIndex;
                    this.positions[x, y] = 0;
                }
            }
        }

        internal void SetTileIndex(int x, int y, int metaTileIndex)
        {
            if (x > 31 || x < 0 || y > 31 || y < 0 || metaTileIndex < 0 || metaTileIndex > 0x3f)
            {
                return;
            }
            metaTileIndices[x, y] = (byte)((metaTileIndices[x, y] & 0xc0) | (metaTileIndex & 0x3f));
        }

        internal int TrackPositionAt(int x, int y)
        {
            if (x > 31 || x < 0 || y > 31 || y < 0)
            {
                return -1;
            }
            return positions[x, y];
        }
    }
}
