#include "VehiblockCommon.as"

void onInit(CBlob@ blob)
{
	blob.Tag("heavy weight");

	core::setVehiblockData(blob); // Set the vehiblock data constructed first
	core::addBlock(blob, vehiblockCreateTile(blob, CMap::tile_castle), Vec2f(1, 0));
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
