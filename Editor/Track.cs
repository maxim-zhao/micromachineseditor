using System.Collections.Generic;
using System.ComponentModel;
using System.Diagnostics.CodeAnalysis;
using System.Drawing;

namespace MicroMachinesEditor
{
    public class Track
    {
        private readonly TrackLayout _layout;
        private readonly TrackTypeData _trackTypeData;
        private string _name;

        [SuppressMessage("ReSharper", "UnusedMember.Global")]
        public string Name { 
            get { return _name; }
            set
            {
                _name = Codec.ValidateString(value, 20);
            } 
        }

        public Track(string name, TrackLayout layout, TrackTypeData trackTypeData)
        {
            _name = name;
            _layout = layout;
            _trackTypeData = trackTypeData;
        }

        public Bitmap GetThumbnail(int size)
        {
            var result = new Bitmap(size, size);
            using (var g = Graphics.FromImage(result))
            {
                using (Bitmap bm = _layout.Render(_trackTypeData.MetaTiles))
                {
                    g.DrawImage(bm, 0, 0, size, size);
                }
            }
            return result;
        }

        internal TrackLayout Layout => _layout;
        internal IList<MetaTile> MetaTiles => _trackTypeData.MetaTiles;
        internal IList<SMSGraphics.Tile> Tiles => _trackTypeData.Tiles;

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
            Desk = 0,
            Breakfast = 1,
            Bathtub = 2,
            Sandpit = 3,
            F1 = 4,
            Garage = 5,
            Tanks = 6,
            Bonus = 7
        }

        [SuppressMessage("ReSharper", "UnusedAutoPropertyAccessor.Global")]
        public VehicleTypes VehicleType { get; set; }

        [SuppressMessage("ReSharper", "UnusedAutoPropertyAccessor.Global")]
        public int TrackIndex { get; set; }
    }
}
