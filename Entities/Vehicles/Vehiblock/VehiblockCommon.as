const string blobFieldPrefix = "Vhb@", // Vehiblock blob field prefix
			 blobFieldPlaced = blobFieldPrefix + "pl";

const int vehiblockSize = 32; // In tiles (width & height)

class BlockPosition
{
	BlockPosition(int offx, int offy)
	{
		x = offx;
		y = offy;
	}
	
	BlockPosition(Vec2f vec)
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

Block[] placedBlocks;

bool isBuildableAt(const BlockPosition position)
{
	return ((position.x == 0) && (position.y == 0)) || // is core block
		   (placedBlocks[BlockPosition(position.x, position.y - 1).absolute()].isPresent()) || // is top present
		   (placedBlocks[BlockPosition(position.x + 1, position.y).absolute()].isPresent()) || // is right present
		   (placedBlocks[BlockPosition(position.x, position.y + 1).absolute()].isPresent()) || // is bottom present
		   (placedBlocks[BlockPosition(position.x - 1, position.y).absolute()].isPresent());   // is left present
}

void syncFromBlob(CBlob@ blob, Block[]&out toUpdate)
{
	blob.get(blobFieldPlaced, toUpdate);
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
