
# Installation guide

To install the CascadiaCode font using the official repository, you can follow these steps:

1. **Open your terminal or command prompt.**

2. **Navigate to the directory where you want to download the font. For example, you can use the command `cd ~/.dotfiles/fonts/`.**

3. Run the following command to download the CascadiaCode font zip file:

```bash
curl -OL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/CascadiaCode.zip
unzip CascadiaCode.zip # On ~/.dotfiles/fonts as a example path
```

4. **Once the download is complete, you can extract the zip file using a tool like `unzip`. For example, you can use the command `unzip CascadiaCode.zip`.**

5. **After extracting the zip file, you should see the font files in the current directory.**

```bash
mkdir -p ~/.local/share/fonts
cp *.ttf ~/.local/share/fonts/
fc-cache -f -v # update cache
```

6. **Now, you can use these font files in your applications or terminal emulator. To verify the installation by checking if the font are available in this system execute this.**

```bash
fc-list | grep -E "Caskaydia"
```


> [!NOTE]
> The above instructions assume you have the necessary dependencies installed on your system, such as `curl` and `unzip`. If not, you may need to install them before proceeding.

# Additional resources

If the installation fails or if you want to install another font, please check the official Nerd Fonts repository for more information and troubleshooting steps: [Nerd Fonts GitHub Repository](https://github.com/ryanoasis/nerd-fonts).