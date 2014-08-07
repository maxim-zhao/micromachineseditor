using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Text;

namespace MicroMachinesEditor
{
    public class Track
    {
        private TrackLayout layout;
        private TrackTypeData trackTypeData;
        private string name;

        public string Name { 
            get { return this.name; }
            set
            {
                this.name = Codec.ValidateString(value, 20);
            } 
        }

        public Track(string name, TrackLayout layout, TrackTypeData trackTypeData)
        {
            this.name = name;
            this.layout = layout;
            this.trackTypeData = trackTypeData;
        }

        public Bitmap GetThumbnail(int size)
        {
            Bitmap result = new Bitmap(size, size);
            Graphics g = Graphics.FromImage(result);
            Bitmap bm = layout.render(trackTypeData.MetaTiles);
            g.DrawImage(bm, 0, 0, size, size);
            return result;
        }

        public TrackLayout Layout { get { return this.layout; } }
        public IList<MetaTile> MetaTiles { get { return this.trackTypeData.MetaTiles; } }
        public IList<SMSGraphics.Tile> Tiles { get { return this.trackTypeData.Tiles; } }

        public int Acceleration { get; set; }

        public int Deceleration { get; set; }

        public int TopSpeed { get; set; }

        public int SteeringSpeed { get; set; }

        public enum VehicleTypeEnum
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

        public VehicleTypeEnum VehicleType { get; set; }

        public int TrackIndex { get; set; }
    }
}
