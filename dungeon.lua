return {
  version = "1.1",
  luaversion = "5.1",
  tiledversion = "1.0.1",
  orientation = "orthogonal",
  renderorder = "right-down",
  width = 15,
  height = 15,
  tilewidth = 32,
  tileheight = 32,
  nextobjectid = 1,
  properties = {},
  tilesets = {
    {
      name = "tileset",
      firstgid = 1,
      filename = "../../../untitled.tsx",
      tilewidth = 32,
      tileheight = 32,
      spacing = 0,
      margin = 0,
      image = "../../../tileset.png",
      imagewidth = 640,
      imageheight = 400,
      tileoffset = {
        x = 0,
        y = 0
      },
      grid = {
        orientation = "orthogonal",
        width = 32,
        height = 32
      },
      properties = {},
      terrains = {},
      tilecount = 240,
      tiles = {
        {
          id = 0,
          properties = {
            ["solid"] = false
          }
        },
        {
          id = 1,
          properties = {
            ["solid"] = false
          }
        },
        {
          id = 2,
          properties = {
            ["solid"] = true
          }
        },
        {
          id = 3,
          properties = {
            ["solid"] = false
          }
        },
        {
          id = 4,
          properties = {
            ["solid"] = false
          }
        },
        {
          id = 5,
          properties = {
            ["solid"] = true
          }
        },
        {
          id = 6,
          properties = {
            ["water"] = false
          }
        },
        {
          id = 7,
          properties = {
            ["solid"] = true
          }
        }
      }
    }
  },
  layers = {
    {
      type = "tilelayer",
      name = "tiles",
      x = 0,
      y = 0,
      width = 15,
      height = 15,
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {},
      encoding = "lua",
      data = {
        1, 8, 1, 8, 1, 8, 1, 8, 1, 8, 1, 8, 1, 8, 1,
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
        1, 8, 1, 8, 1, 8, 1, 8, 1, 8, 1, 8, 1, 8, 1,
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
        1, 8, 1, 1, 2, 2, 2, 2, 2, 2, 2, 1, 6, 1, 6,
        1, 1, 1, 1, 2, 3, 3, 3, 3, 3, 2, 1, 1, 1, 1,
        1, 8, 1, 1, 2, 3, 2, 2, 2, 3, 2, 1, 6, 1, 6,
        1, 1, 1, 1, 2, 3, 2, 7, 2, 5, 2, 2, 2, 2, 2,
        1, 8, 1, 1, 2, 3, 2, 2, 2, 3, 2, 1, 6, 1, 6,
        1, 1, 1, 1, 2, 3, 3, 5, 3, 3, 2, 1, 1, 1, 1,
        1, 8, 1, 1, 2, 2, 2, 2, 2, 2, 2, 1, 6, 1, 6,
        1, 1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1,
        1, 8, 1, 8, 1, 1, 6, 2, 6, 1, 1, 8, 1, 8, 1,
        1, 1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1,
        1, 8, 1, 8, 1, 1, 6, 2, 6, 1, 1, 8, 1, 8, 1
      }
    },
    {
      type = "tilelayer",
      name = "mobs",
      x = 0,
      y = 0,
      width = 15,
      height = 15,
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
      }
    }
  }
}