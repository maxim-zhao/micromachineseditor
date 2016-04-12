using System;
using System.Collections.Generic;
using System.Drawing;

namespace MicroMachinesEditor
{
    public class TrackTypeData
    {
        public TrackTypeData(byte[] file, int trackType)
        {
            // Most of the tables are at the start of a page given by a table at 0x3e3a
            int trackTypeDataPageNumber = Codec.TrackTypeDataPageNumber(file, trackType);
            int tableOffset = trackTypeDataPageNumber * 16 * 1024;

            // But there's tile data (and other stuff) at 0x3dc8
            byte trackTypeTileDataPageNumber = file[0x3dc8 + trackType];
            byte[] offset1Buffer = new byte[] { file[0x3ddc + trackType], file[0x3de4 + trackType] };
            int offsetTiles = Codec.AbsoluteOffset(trackTypeTileDataPageNumber, BitConverter.ToUInt16(offset1Buffer, 0));

            // And the palette table at 0x17ec2. Palettes are in page 5.
            ushort offsetPalette = BitConverter.ToUInt16(file, 0x17ec2 + trackType * 2);
            int absoluteOffsetPalette = Codec.AbsoluteOffset(5, offsetPalette);

            // First load the palette
            Palette = SMSGraphics.ReadPalette(file, absoluteOffsetPalette, 32);

            // Then the tiles
            Tiles = Codec.LoadTiles(file, offsetTiles, Palette);

            // Metatiles next
            MetaTiles = Codec.LoadMetaTiles(file, trackType, Tiles);
        }

        public IList<Color> Palette { get; private set; }

        public IList<SMSGraphics.Tile> Tiles { get; private set; }

        public IList<MetaTile> MetaTiles { get; private set; }
    }
}
