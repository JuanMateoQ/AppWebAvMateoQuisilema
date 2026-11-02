using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.Security;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace WebAppPoliMusicV2
{
    public partial class Song : System.Web.UI.Page
    {
        string strConnString = ConfigurationManager.ConnectionStrings["BDD_PoliMusicConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!Page.IsPostBack)
            {
                LoadAuthenticatedUser();
                BindSongs();
            }
        }

        private void LoadAuthenticatedUser()
        {
            Entities.User user = Session[Util.Constants.USER] as Entities.User;
            string userName = string.Empty;
            if (user != null && !string.IsNullOrEmpty(user.UserName))
            {
                userName = user.UserName;
            }
            else if (User.Identity.IsAuthenticated)
            {
                userName = User.Identity.Name;
            }

            if (string.IsNullOrEmpty(userName))
            {
                Response.Redirect("~/Login.aspx", true);
                return;
            }

            lblUserName.Text = Server.HtmlEncode(userName);
            litInitial.Text = Server.HtmlEncode(userName.Substring(0, 1).ToUpper());

            if (user != null && !string.IsNullOrEmpty(user.Photo))
            {
                imgUserPhoto.ImageUrl = ResolveUrl(user.Photo);
                imgUserPhoto.Visible = true;
            }
        }

        private void BindSongs()
        {
            List<Entities.Song> songs = new List<Entities.Song>();
            DataTable dtSongs = new BLL.Song(strConnString).Read();

            if (dtSongs != null)
            {
                foreach (DataRow row in dtSongs.Rows)
                {
                    songs.Add(MapSong(row));
                }
            }

            lblCount.Text = songs.Count + (songs.Count == 1 ? " song" : " songs");

            if (songs.Count == 0)
            {
                pnlSongs.Visible = false;
                lblMessage.Text = "There are no songs registered yet.";
                return;
            }

            rptSongs.DataSource = songs;
            rptSongs.DataBind();
        }

        private Entities.Song MapSong(DataRow row)
        {
            Entities.Song song = new Entities.Song();
            song.ID = Convert.ToInt32(row["ID_SONG"]);
            song.Name = row["SONG_NAME"].ToString();
            song.Path = row["SONG_PATH"].ToString();
            song.Plays = (row["PLAYS"] == DBNull.Value) ? 0 : Convert.ToInt32(row["PLAYS"]);
            return song;
        }

        public string Encode(object value)
        {
            return (value == null) ? string.Empty : Server.HtmlEncode(value.ToString());
        }

        protected void LnkLogout_Click(object sender, EventArgs e)
        {
            FormsAuthentication.SignOut();
            Session.Clear();
            Session.Abandon();
            Response.Redirect("~/Login.aspx", true);
        }

        [WebMethod(EnableSession = true)]
        public static int RegisterPlay(int idSong)
        {
            if (idSong <= 0)
            {
                return 0;
            }
            string connectionString = ConfigurationManager.ConnectionStrings["BDD_PoliMusicConnectionString"].ConnectionString;
            return new BLL.Song(connectionString).RegisterPlay(idSong);
        }
    }
}
