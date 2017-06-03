#include "VehiblockCommon.as"

void onInit(CBlob@ blob)
{
	blob.Tag("heavy weight");

	vData = VehiblockData();
	syncToBlob(blob);

	vData.insert(CMap::tile_castle, BlockPosition(-1, 0).absolute());
	vData.insert(CMap::tile_ground, BlockPosition(0, -1).absolute());
	vData.insert(CMap::tile_castle, BlockPosition(-1, 1).absolute());
	vData.insert(CMap::tile_castle, BlockPosition(-1, -2).absolute());
	vData.remove(BlockPosition(-1, -2).absolute());

	syncToBlob(blob);
}

void onTick(CBlob@ blob)
{
	syncFromBlob(blob);

	//print("placedBlocks.size() == " + placedBlocks.size());

	// DEBUG
	CBlob@ localBlob = getLocalPlayerBlob();

	if (localBlob !is null)
	{
		BlockPosition offset = positionFromWorldPos(blob, localBlob.getAimPos());
		//print("Aim relative to core : " + offset.x + "; " + offset.y);

		if (getControls().isKeyJustPressed(KEY_KEY_R))
		{
			vData.insert(CMap::tile_ground, positionFromWorldPos(blob, localBlob.getAimPos()).absolute());
		}
		else if (getControls().isKeyJustPressed(KEY_KEY_U))
		{
			vData.remove(positionFromWorldPos(blob, localBlob.getAimPos()).absolute());
		}
	}
	// END OF DEBUG

	if (vData.insertedBlockLastTick && !vData.toRemove.empty())
	{
		for (int i = 0; i < vData.toRemove.size(); i++)
		{
			vData.unsafe_remove(blob, vData.toRemove[i]);
		}

		vData.toRemove.clear();
		vData.insertedBlockLastTick = false;
	}
	else
	{
		for (int i = 0; i < vData.toInsert.size(); i++)
		{
			vData.unsafe_insert(blob, BlockPosition(vData.toInsert[i].offset), vData.toInsert[i].type);
		}
		vData.toInsert.clear();
		vData.insertedBlockLastTick = true;
	}

	syncToBlob(blob);
}

// Allow to carry the vehiblock only when it is light enough
bool canBePickedUp(CBlob@ blob, CBlob@ byBlob)
{
	return blob.getMass() <= 10000;
}

f32 onHit(CBlob@ blob, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	// TODO implement vehiblock single block damaging & collapsing
	return 0.f;
}
