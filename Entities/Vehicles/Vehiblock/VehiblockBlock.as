// CONST GLOBAL PROPERTIES
const int vehiblockSize = 32; // Width and height of the vehicle.

class BlockPosition
{
	BlockPosition(const int offset)
	{
		x = (offset % vehiblockSize) - (vehiblockSize / 2);
		y = (offset / vehiblockSize) - (vehiblockSize / 2);
	}

	BlockPosition(const int offx, const int offy)
	{
		x = offx;
		y = offy;
	}

	BlockPosition(const Vec2f vec)
	{
		x = vec.x;
		y = vec.y;
	}

	Vec2f toVec() const
	{
		float tileSize = getMap().tilesize;
		return Vec2f(-x * tileSize, y * tileSize);
	}

	int absolute() const
	{
		return x + (vehiblockSize / 2) + ((y + vehiblockSize / 2) * vehiblockSize);
	}

	// Offset from the main core tile
	int x, y;
};

class Block
{
	u16 type = 0;
	int shapeID, layerID;

	Block(const u16 _type, const int _shapeID, const int _layerID)
	{
		type = _type;
		shapeID = _shapeID;
		layerID = _layerID;
	}

	bool isPresent() const
	{
		return type != 0;
	}
};

class PlannedBlock
{
	PlannedBlock(const u16 _type, const int _offset)
	{
		type = _type;
		offset = _offset;
	}

	u16 type = 0;
	int offset;
};

class RemovedBlock
{
	RemovedBlock(Block@ _block, const int _offset)
	{
		@block = @_block;
		offset = _offset;
	}

	Block@ block;
	int offset;
};
