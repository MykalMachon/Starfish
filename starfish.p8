pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- starfish ★
-- a stardew valley fishing demake.

-- https://mykal.codes/

function _init()
	poke(0x5f2d, 0x1) -- enable mouse

	cartdata("mykalcodes_starfish_1")
	high_score = dget(0)
	debug = true -- global flag
	
	create_player(
		62,
		12,
		24,
		96
	)
	create_fish("trout")
	create_gs()
end

function _update()
	update_player()
	update_fish()
	update_gs()
end

function _draw()
	cls()
	draw_player()
	draw_fish()
	
	
	if debug then
		is_catching = catching() and "catching!" or "not catching"
		
		print(
		is_catching,
		 0,
		 48)
		
		print(
			"catch %"..gs.f_cp*100,
			0,
			56)
			
		print(
			"caught: "..gs.f_caught,
			0,
			64)
	end
	-- map(0,0,0,0)
end
-->8
-- player mgr

-- org_x is the x origin
-- org_y is the y origin
-- length is the player length
-- height is playspace height
function create_player(
	org_x,
	org_y,
	length,
	box_size
)
	p={}
	p.org_x=org_x
	p.org_y=org_y
	p.x=org_x
	p.y=org_y+flr(box_size/2)-- y pos of tail
	p.dy=0 -- dir y speed
	p.my=3 -- max y speed
	p.l=length -- piece length in px
	p.dir="down"
	p.box_size = box_size
	
	p.grav = 0.5
	p.powr = 1
	-- p.fric = 0.5
end

function update_player()
	p.dy+=p.grav
	if(btn(❎) or stat(34)==1) p.dy-=p.powr -- move up
	
	-- downward cases
	if (p.dy > 0) then 
		p.dir="down"
		next_y_pos = (p.y+p.l)+p.dy
		bott_y_pos = (p.org_y+p.box_size)
		
		-- check if at bottom
		if (next_y_pos >= bott_y_pos) p.dy=0 p.y=bott_y_pos-p.l
	end
	
	-- upward case 
	if (p.dy < 0) then
		p.dir="up"
		next_y_pos = p.y + p.dy
		top_y_pos = p.org_y
		
		-- check if at top
		-- todo: cleanup bounc function
		if(next_y_pos<top_y_pos) p.dy=-1*(p.dy*0.5) p.y=top_y_pos
	end
	
	p.y += p.dy

	-- maintain max dy 
	if abs(p.dy - 0.1) >= p.my then 
		if(p.dy > p.my) p.dy=p.my
		if(p.dy < p.my) p.dy=-1*p.my
	end
end

function draw_player()
	if debug then
		print("dy: ".. p.dy, 0, 0)
		print("p: "..p.y, 0, 12)
		print("dir: "..p.dir, 0, 24)
		print("mouse: "..stat(34), 0, 36)
	end
	
	--draw border
	rectfill(
		(p.org_x-1),
		(p.org_y-1),
		(p.org_x+6),
		(p.org_y+1) + p.box_size,
		1
	)
	
	--infill black
	rectfill(
		(p.org_x-1)+1,
		(p.org_y+1)-1,
		(p.org_x+5),
		(p.org_y) + p.box_size,
		0
	)
	
	-- draw "player"
	rectfill(
		p.x,
		p.y,
		p.x+5,
		p.y+(p.l),
		12
	)
end
-->8
-- fish handler 
-- handles all the fish logic
fish_types={}


function create_fish(fish_name)
	-- todo: create a fish
	f={}
	f.org_x = p.org_x-1
	f.org_y = p.org_y + rnd(p.box_size)
	f.x=f.org_x
	f.y=f.org_y
	f.spr=flr(1 + rnd(3))
	f.name=fish_name
	f.dir="down"
end

function del_fish()
	-- todo: seperate win/loss
	sfx(0)
	f = nil
end

function update_fish()
	-- todo: make this better
	new_f = f.org_y + sin(time() * 0.3) * p.box_size/2
	
	if new_f < p.org_y then 
		f.y = p.org_y 
	elseif new_f > (p.org_y + p.box_size - 8) then
		f.y = p.org_y+p.box_size - 8
	else
		f.y = new_f
	end 
	
end

function draw_fish()
	-- todo: draw fish
	spr(f.spr, f.x, f.y)
end
-->8
-- game state
-- manages game state

function create_gs()
	-- creates game state
	gs={}
	gs.f_caught=0 -- # fish caught
	gs.f_cp=0 -- catch %
end

function catching()
	-- checks if player is 
	-- "catching" the fish. 
	player_exists = p.y and p.x  
	fish_exists = f.y and f.x
	
	if 
		not player_exists 
		or 
		not fish_exists
	then 
		return false
	end
	
	if 
		(flr(f.y) >= p.y)
	 and 
	 (f.y < p.y + p.l) 
	then
		return true
	else
		return false
	end
	
end

function update_gs()

	if catching() then 
		if gs.f_cp >= 1 then
			gs.f_caught += 1
			gs.f_cp = 0
			-- reset fish
			del_fish()
			create_fish()
		else 
			gs.f_cp += 0.01
		end
	elseif (gs.f_cp > 0) then
		gs.f_cp -= 0.01
	end
	
end


__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000006660000099900000eee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000006066666090999990e0eeeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000016666166a99991998eeee1ee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000006666666099999990eeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000616666619a99999ae8eeeee8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000010166610a0a999a0808eee80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000011100000aaa0000088800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000d00000000000000213502e3402e3302e3202e31031300313000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
