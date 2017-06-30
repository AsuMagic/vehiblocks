#include "../VehiblockCommon.as"

void onInit(CBlob@ blob)
{
	ShapeConsts@ consts = blob.getShape().getConsts();
	consts.collideWhenAttached = true;
}
