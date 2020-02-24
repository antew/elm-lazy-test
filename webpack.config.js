const path = require("path");
const HtmlWebpackPlugin = require("html-webpack-plugin");
const MiniCssExtractPlugin = require("mini-css-extract-plugin");
const CopyPlugin = require("copy-webpack-plugin");

module.exports = (_env, options) => ({
  output: {
    publicPath: "/lazy/",
    chunkFilename: "[name].[contenthash].bundle.js",
    filename: "[name].[contenthash].js",
    path: path.resolve(__dirname, "./dist")
  },
  externals: {
    moment: "moment"
  },
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        loader: "babel-loader",
        options: {
          presets: ["@babel/preset-env"]
        }
      },
      {
        test: /\.css$/,
        use: [MiniCssExtractPlugin.loader, "css-loader", "postcss-loader"]
      },
      {
        test: /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        loader: "elm-webpack-loader",
        options: {
          // debug: options.mode === "development",
          // optimize: options.mode === "production",
          debug: false,
          optimize: true,
          pathToElm: "shelm"
        }
      }
    ]
  },
  plugins: [
    new HtmlWebpackPlugin({ template: "static/index.html" }),
    new MiniCssExtractPlugin({ filename: "[name].[contenthash].css" }),
    new CopyPlugin([{ from: "static/", to: "./" }])
  ],
  devServer: {
    inline: true,
    stats: { colors: true },
    historyApiFallback: true,
    overlay: true,
    port: 3001
  }
});
