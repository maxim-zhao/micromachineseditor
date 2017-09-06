using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;

namespace MicroMachinesEditor
{
    public class TrackTypeData
    {
        public enum TrackType
        {
            SportsCars = 0,
            FourByFour = 1,
            Powerboats = 2,
            TurboWheels = 3,
            FormulaOne = 4,
            Warriors = 5,
            Tanks = 6,
            RuffTrux = 7,
            Choppers = 8
        }

        public TrackTypeData(byte[] file, TrackType trackType)
        {
            // Most of the tables are at the start of a page given by a table at 0x3e3a
//            int trackTypeDataPageNumber = Codec.TrackTypeDataPageNumber(file, trackType);
//            int tableOffset = trackTypeDataPageNumber * 16 * 1024;

            // But there's tile data (and other stuff) at 0x3dc8
            byte trackTypeTileDataPageNumber = file[Codec.Offset(0x3dc8, trackType)];
            byte[] offset1Buffer = { file[Codec.Offset(0x3ddc, trackType)], file[Codec.Offset(0x3de4, trackType)] };
            int offsetTiles = Codec.AbsoluteOffset(trackTypeTileDataPageNumber, BitConverter.ToUInt16(offset1Buffer, 0));

            // And the palette table at 0x17ec2. Palettes are in page 5.
            ushort offsetPalette = BitConverter.ToUInt16(file, Codec.Offset(0x17ec2, trackType, 2));
            int absoluteOffsetPalette = Codec.AbsoluteOffset(5, offsetPalette);

            // First load the palette
            Palette = SMSGraphics.ReadPalette(file, absoluteOffsetPalette, 32);

            // Then the tiles
            Tiles = Codec.LoadTiles(file, offsetTiles, Palette);

            // Metatiles next
            MetaTiles = Codec.LoadMetaTiles(file, trackType, Tiles);
        }

        public IList<Color> Palette { get; }

        public IReadOnlyList<SMSGraphics.Tile> Tiles { get; }

        public IList<MetaTile> MetaTiles { get; }
    }
}
