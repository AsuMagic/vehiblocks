const string blobFieldPrefix = "Vhb@", // Vehiblock blob field prefix
			 blobFieldPlaced = blobFieldPrefix + "pl",
			 blobFieldInsert = blobFieldPrefix + "in",
			 blobFieldRemove = blobFieldPrefix + "rm";

const int vehiblockSize = 32; // In tiles (width & height)

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

Block[] placedBlocks;

PlannedBlock[] toInsert;
Block@[] toRemove;

bool isBuildableAt(const BlockPosition position)
{
	return ((position.x == 0) && (position.y == 0)) || // is core block
		   (placedBlocks[BlockPosition(position.x, position.y - 1).absolute()].isPresent()) || // is top present
		   (placedBlocks[BlockPosition(position.x + 1, position.y).absolute()].isPresent()) || // is right present
		   (placedBlocks[BlockPosition(position.x, position.y + 1).absolute()].isPresent()) || // is bottom present
		   (placedBlocks[BlockPosition(position.x - 1, position.y).absolute()].isPresent());   // is left present
}

void syncBlocksFromBlob(CBlob@ blob)
{
	blob.get(blobFieldPlaced, placedBlocks);
}

void syncUpdatesFromBlob(CBlob@ blob)
{
	blob.get(blobFieldInsert, toInsert);
	blob.get(blobFieldRemove, toRemove);
}

void syncFromBlob(CBlob@ blob)
{
	syncBlocksFromBlob(blob);
	syncUpdatesFromBlob(blob);
}

void syncBlocksToBlob(CBlob@ blob)
{
	blob.set(blobFieldPlaced, placedBlocks);
}

void syncUpdatesToBlob(CBlob@ blob)
{
	blob.set(blobFieldInsert, toInsert);
	blob.set(blobFieldRemove, toRemove);
}

void syncToBlob(CBlob@ blob)
{
	syncBlocksToBlob(blob);
	syncUpdatesToBlob(blob);
}

BlockPosition positionFromWorldPos(CBlob@ blob, const Vec2f blockPosition)
{
	const Vec2f blobPosition = blob.getPosition();
	const float tileSize = getMap().tilesize;
	Vec2f flat((blockPosition.x - blobPosition.x) / tileSize, (blockPosition.y - blobPosition.y) / tileSize);
	flat.RotateBy(-blob.getAngleDegrees());

	if (blob.isFacingLeft())
	{
		flat.x = -flat.x;
	}

	return BlockPosition(flat);
}
