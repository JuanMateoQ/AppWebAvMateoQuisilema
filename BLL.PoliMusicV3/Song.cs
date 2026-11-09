using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BLL.PoliMusicV3
{
    public class Song
    {
        private string strConnectionString;
        public Song(string strConnString)
        {
            strConnectionString = strConnString;
        }
        public int Save(EntityLayer.PoliMusicV3.Song song)
        {
            return new DAL.PoliMusicV3.Song(strConnectionString).Save(song);
        }
        public DataTable Read()
        {
            return new DAL.PoliMusicV3.Song(strConnectionString).Read();
        }
        public DataTable GetById(int idSong)
        {
            return new DAL.PoliMusicV3.Song(strConnectionString).GetById(idSong);
        }
        public int Update(EntityLayer.PoliMusicV3.Song song)
        {
            return new DAL.PoliMusicV3.Song(strConnectionString).Update(song);
        }
        public int Delete(int idSong)
        {
            return new DAL.PoliMusicV3.Song(strConnectionString).Delete(idSong);
        }
        public int RegisterPlay(int idSong)
        {
            if (idSong <= 0)
            {
                return 0;
            }
            new DAL.PoliMusicV3.Song(strConnectionString).RegisterPlay(idSong);
            return new DAL.PoliMusicV3.Song(strConnectionString).GetPlays(idSong);
        }
        public int GetPlays(int idSong)
        {
            return new DAL.PoliMusicV3.Song(strConnectionString).GetPlays(idSong);
        }
        public string ValidationsRequired(EntityLayer.PoliMusicV3.Song song)
        {
            if (song == null)
            {
                return "Song is required!";
            }
            if (string.IsNullOrEmpty(song.Name) || song.Name.Trim() == string.Empty)
            {
                return "Song name is required!";
            }
            if (string.IsNullOrEmpty(song.Path) || song.Path.Trim() == string.Empty)
            {
                return "Song path is required!";
            }
            if (song.Plays < 0)
            {
                return "Plays cannot be negative!";
            }
            return string.Empty;
        }
    }
}
