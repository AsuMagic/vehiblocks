#include "VehiblockCommon.as"

int layerID = 0, shapeID = 0;
bool insertedBlockLastTick = false;

void onInit(CBlob@ blob)
{
	blob.Tag("heavy weight");

	placedBlocks.clear();
	placedBlocks.resize(vehiblockSize * vehiblockSize);

	syncBlocksToBlob(blob);
	syncUpdatesToBlob(blob);

	toInsert.push_back(PlannedBlock(CMap::tile_castle, BlockPosition(-1, 0).absolute()));
	toInsert.push_back(PlannedBlock(CMap::tile_ground, BlockPosition(0, -1).absolute()));
	toInsert.push_back(PlannedBlock(CMap::tile_castle, BlockPosition(-1, 1).absolute()));
	toInsert.push_back(PlannedBlock(CMap::tile_castle, BlockPosition(-1, -2).absolute()));
	toRemove.push_back(@placedBlocks[BlockPosition(-1, -2).absolute()]);

	syncBlocksToBlob(blob);
	syncUpdatesToBlob(blob);
}

void onTick(CBlob@ blob)
{
	// DEBUG
	CBlob@ localBlob = getLocalPlayerBlob();

	if (localBlob !is null)
	{
		BlockPosition offset = positionFromWorldPos(blob, localBlob.getAimPos());
		//print("Aim relative to core : " + offset.x + "; " + offset.y);
	}

	syncFromBlob(blob);

	if (insertedBlockLastTick && !toRemove.empty())
	{
		for (int i = 0; i < toRemove.size(); i++)
		{
			print("Removing block #" + i + " from queue");
			unsafe_removeBlock(blob, toRemove[i]);
		}

		toRemove.clear();
		insertedBlockLastTick = false;
	}
	else
	{
		for (int i = 0; i < toInsert.size(); i++)
		{
			print("Setting block #" + i + " from queue, type " + toInsert[i].type + ", offset " + toInsert[i].offset);
			unsafe_setBlock(blob, BlockPosition(toInsert[i].offset), toInsert[i].type);
		}
		toInsert.clear();
		insertedBlockLastTick = true;
	}

	syncToBlob(blob);
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

// The "unsafe" methods exists because of the KAG engine bug - https://forum.thd.vg/threads/obscure-cshape-removeshape-method.26842/#post-398411
// This bug makes using both RemoveShape and AddShape within a tick unreliable.
// As a workaround vehiblock exposes a toInsert and a toRemove list. When/if this bug gets fixed it can be done directly again.
void unsafe_removeBlock(CBlob@ blob, Block@ block)
{
	if (block.isPresent())
	{
		print("Erasing shape ID#" + block.shapeID);
		blob.getShape().RemoveShape(block.shapeID);

		// TODO this could be done faster by sorting the array first
		for (int i = 0; i < toRemove.size(); i++)
		{
			if (toRemove[i].shapeID > block.shapeID)
			{
				--toRemove[i].shapeID;
			}
		}

		// Align other shapeIDs to the current one
		for (int i = 0; i < placedBlocks.size(); i++)
		{
			if (placedBlocks[i].shapeID > block.shapeID)
			{
				--placedBlocks[i].shapeID;
			}
		}

		blob.getSprite().RemoveSpriteLayer("t" + block.layerID);

		--shapeID;
	}
	else
	{
		warn("Tried to erase non-present block");
	}

	block.type = 0; // Set to air tile
}

void unsafe_setBlock(CBlob@ blob, const BlockPosition position, const u16 tile)
{
	Block@ oldBlock = placedBlocks[position.absolute()];
	if (oldBlock !is null && oldBlock.isPresent())
		toRemove.push_back(oldBlock);

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

	placedBlocks[position.absolute()] = Block(tile, ++shapeID, layerID);
}
