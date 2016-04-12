using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Drawing.Drawing2D;

namespace MicroMachinesEditor
{
    public class Track
    {
        private readonly TrackLayout _layout;
        private readonly TrackTypeData _trackTypeData;
        private string _name;

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
                using (Bitmap bm = _layout.render(_trackTypeData.MetaTiles))
                {
                    g.DrawImage(bm, 0, 0, size, size);
                }
            }
            return result;
        }

        internal TrackLayout Layout { get { return _layout; } }
        internal IList<MetaTile> MetaTiles { get { return _trackTypeData.MetaTiles; } }
        internal IList<SMSGraphics.Tile> Tiles { get { return _trackTypeData.Tiles; } }

        [Description("The rate at which the vehicle speeds up when accelerating. Original values are 6 (strong acceleration) to 18 (weak).")]
        public int AccelerationDelay { get; set; }

        [Description("How long it takes to decelerate (when not accelerating). Original values are 5 (strong deceleration) to 39 (weak).")]
        public int DecelerationDelay { get; set; }

        [Description("Vehicle top speed, from 1 to 15. Larger values cause glitches. Original values are 7 (slow) to 11 (fast).")]
        public int TopSpeed { get; set; }

        [Description("How long it takes to steer. Original values are 6 (fast) to 9 (slow).")]
        public int SteeringDelay { get; set; }

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

        public VehicleTypes VehicleType { get; set; }

        public int TrackIndex { get; set; }
    }
}
