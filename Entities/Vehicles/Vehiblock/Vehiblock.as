#include "VehiblockCommon.as"

int layerID = 0;

void onInit(CBlob@ blob)
{
	placedBlocks.resize(vehiblockSize * vehiblockSize);
	blob.set(blobFieldPlaced, placedBlocks);
	
	server_setBlock(blob, BlockPosition(-1, 0), CMap::tile_castle);
	server_setBlock(blob, BlockPosition(0, -1), CMap::tile_ground);
	//server_setBlock(blob, BlockPosition(0, 1), CMap::tile_ground);
	//server_removeBlock(blob, BlockPosition(0, 1));
}

void onTick(CBlob@ blob)
{
	CBlob@ localBlob = getLocalPlayerBlob();
	
	if (localBlob !is null)
	{
		BlockPosition offset = positionFromWorldPos(blob, localBlob.getAimPos());
		//print("Aim relative to core : " + offset.x + "; " + offset.y);
	}
}

// Allow to carry the vehiblock only when it is light enough
bool canBePickedUp(CBlob@ blob, CBlob@ byBlob)
{
	return blob.getMass() <= 7000;
}

f32 onHit(CBlob@ blob, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	// TODO implement vehiblock single block damaging & collapsing
	return 0.f;
}

void server_removeBlock(CBlob@ blob, const BlockPosition position)
{
	Block@ block = @placedBlocks[position.absolute()];
	if (block.isPresent())
	{
		//blob.getShape().RemoveShape(block.shapeID + 1); // Gotta see how RemoveShape works (simple index in a vector i guess)
		blob.getSprite().RemoveSpriteLayer("t" + block.layerID);
	}
	
	block.type = 0; // Set to air tile
}

void server_setBlock(CBlob@ blob, const BlockPosition position, const u16 tile)
{
	server_removeBlock(blob, position);
	
	// Add the shape and the sprite layer
	CShape@ shape = blob.getShape();	
	
	// TODO optimize the shape so we don't get just tons of useless vertices
	const float tileSize = getMap().tilesize;
	Vec2f rectTL = Vec2f((position.x * tileSize) - (tileSize / 2.f), (position.y * tileSize) - (tileSize / 2.f));
	Vec2f[] tileRect =
	{
		Vec2f(rectTL.x, rectTL.y),
		Vec2f(rectTL.x + tileSize, rectTL.y),
		Vec2f(rectTL.x + tileSize, rectTL.y + tileSize),
		Vec2f(rectTL.x, rectTL.y + tileSize)
	};
	shape.AddShape(tileRect);
	
	// TODO handle damage levels
	CSpriteLayer@ spriteLayer = blob.getSprite().addSpriteLayer("t" + ++layerID, "world.png", 8, 8);
	spriteLayer.SetOffset(position.toVec());
	spriteLayer.SetFrameIndex(tile);
	
	placedBlocks[position.absolute()] = Block(tile, /*shapeID*/0, layerID);
}
