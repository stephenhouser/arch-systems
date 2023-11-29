class UserConfig </ help="Intro Layout Options" />
{
	</ label="Color", help="The theme color", options="Green,Red,Blue" order=1 />
	color="Green"
}

fe.layout.width = 640
fe.layout.height = 480

local bg = fe.add_image( "bg.png", 0, 0, fe.layout.width, fe.layout.height )

local title = fe.add_text( "[DisplayName]", 0, 10, fe.layout.width, 35 )
title.set_rgb(255, 0, 255)

local marquee = fe.add_artwork("marquee", 338, 303, 287, 75)
marquee.preserve_aspect_ratio = false;

local snap = fe.add_artwork("snap", 338, 70, 287, 214)

local list = fe.add_listbox(9, 75, 311, 385)
list.rows = 20
list.charsize = 14
//list.set_selbg_rgb(30, 180, 30)
list.align = Align.MiddleLeft

fe.add_text("[DisplayName]", 338, 385, 300, 20)
fe.add_text("[FilterName]", 338, 405, 300, 20)
fe.add_text("[ListEntry] of [ListSize]", 338, 425, 300, 30)

local config = fe.get_config()
bg.set_rgb(255, 0, 255)
title.set_rgb(255, 255, 255)
list.set_selbg_rgb(255, 0, 255)
