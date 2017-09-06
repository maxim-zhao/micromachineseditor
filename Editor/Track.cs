using System.Collections.Generic;
using System.ComponentModel;
using System.Diagnostics.CodeAnalysis;
using System.Drawing;

namespace MicroMachinesEditor
{
    public class Track
    {
        private string _name;
        internal readonly byte[] _file;

        [SuppressMessage("ReSharper", "UnusedMember.Global")]
        public string Name
        { 
            get => _name;
            set => _name = Codec.ValidateString(value, 20);
        }

        public Track(string name, TrackLayout layout, TrackTypeData trackTypeData, byte[] file)
        {
            _name = name;
            _file = file;
            Layout = layout;
            TrackTypeData = trackTypeData;
        }

        public Bitmap GetThumbnail(int size)
        {
            var result = new Bitmap(size, size);
            using (var g = Graphics.FromImage(result))
            {
                using (var bm = Layout.Render(TrackTypeData.MetaTiles))
                {
                    g.DrawImage(bm, 0, 0, size, size);
                }
            }
            return result;
        }

        internal TrackLayout Layout { get; }

        internal IList<MetaTile> MetaTiles => TrackTypeData.MetaTiles;
        internal IReadOnlyList<SMSGraphics.Tile> Tiles => TrackTypeData.Tiles;
        internal TrackTypeData TrackTypeData { get; }

        [Description("The rate at which the vehicle speeds up when accelerating. Original values are 6 (strong acceleration) to 18 (weak).")]
        [SuppressMessage("ReSharper", "UnusedAutoPropertyAccessor.Global")]
        public int AccelerationDelay { get; set; }

        [Description("How long it takes to decelerate (when not accelerating). Original values are 5 (strong deceleration) to 39 (weak).")]
        [SuppressMessage("ReSharper", "UnusedAutoPropertyAccessor.Global")]
        public int DecelerationDelay { get; set; }

        [Description("Vehicle top speed, from 1 to 15. Larger values cause glitches. Original values are 7 (slow) to 11 (fast).")]
        [SuppressMessage("ReSharper", "UnusedAutoPropertyAccessor.Global")]
        public int TopSpeed { get; set; }

        [Description("How long it takes to steer. Original values are 6 (fast) to 9 (slow).")]
        [SuppressMessage("ReSharper", "UnusedAutoPropertyAccessor.Global")]
        public int SteeringDelay { get; set; }

        [SuppressMessage("ReSharper", "UnusedMember.Global")]
        public enum VehicleTypes
        {
            Sportscars = 0,
            FourByFour = 1,
            Powerboats = 2,
            TurboWheels = 3,
            FormulaOne = 4,
            Warriors = 5,
            Tanks = 6,
            RuffTrux = 7
        }

        [SuppressMessage("ReSharper", "UnusedAutoPropertyAccessor.Global")]
        public VehicleTypes VehicleType { get; set; }

        [SuppressMessage("ReSharper", "UnusedAutoPropertyAccessor.Global")]
        public int TrackIndex { get; set; }
    }
}
