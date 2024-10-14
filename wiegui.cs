using System;
using System.Management;
using System.Windows.Forms;
using System.Drawing;

namespace WEIGUI
{
    public partial class MainForm : Form
    {
        public MainForm()
        {
            InitializeComponent();
            InitializeThemeComboBox();
            LoadWEIScores();
        }

        private void InitializeThemeComboBox()
        {
            ComboBox themeComboBox = new ComboBox
            {
                Location = new Point(10, 10),
                Width = 150
            };
            themeComboBox.Items.AddRange(new string[] { "Windows 7", "Windows Vista", "Windows XP" });
            themeComboBox.SelectedIndexChanged += ThemeComboBox_SelectedIndexChanged;
            this.Controls.Add(themeComboBox);
        }

        private void ThemeComboBox_SelectedIndexChanged(object sender, EventArgs e)
        {
            ComboBox comboBox = sender as ComboBox;
            string selectedTheme = comboBox.SelectedItem.ToString();
            ApplyTheme(selectedTheme);
        }

        private void ApplyTheme(string theme)
        {
            switch (theme)
            {
                case "Windows 7":
                    this.BackColor = Color.LightBlue;
                    foreach (Control control in this.Controls)
                    {
                        control.Font = new Font("Segoe UI", 10);
                        control.ForeColor = Color.Black;
                    }
                    break;
                case "Windows Vista":
                    this.BackColor = Color.LightGreen;
                    foreach (Control control in this.Controls)
                    {
                        control.Font = new Font("Arial", 10);
                        control.ForeColor = Color.DarkGreen;
                    }
                    break;
                case "Windows XP":
                    this.BackColor = Color.LightGray;
                    foreach (Control control in this.Controls)
                    {
                        control.Font = new Font("Tahoma", 10);
                        control.ForeColor = Color.DarkBlue;
                    }
                    break;
            }
        }

        private void LoadWEIScores()
        {
            try
            {
                ManagementObjectSearcher searcher = new ManagementObjectSearcher("root\\CIMV2", "SELECT * FROM Win32_WinSAT");
                foreach (ManagementObject queryObj in searcher.Get())
                {
                    txtProcessor.Text = queryObj["CPUScore"].ToString();
                    txtMemory.Text = queryObj["MemoryScore"].ToString();
                    txtGraphics.Text = queryObj["GraphicsScore"].ToString();
                    txtGamingGraphics.Text = queryObj["D3DScore"].ToString();
                    txtDisk.Text = queryObj["DiskScore"].ToString();
                }
            }
            catch (Exception e)
            {
                MessageBox.Show("An error occurred while retrieving WEI scores: " + e.Message);
            }
        }
    }
}