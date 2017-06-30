const string fieldPrefix = "$v", // Vehiblock blob field prefix
			 coreFieldData = fieldPrefix + "d", // name to the data field
			 blockBlobName = "vehiblock_block",
			 blockInitCommandName = fieldPrefix + "i",
			 attachmentName = fieldPrefix + "a";

// Hold vehiblock core data
class VehiblockData
{
	CBlob@[] blobs;

	float mass;
	Vec2f centerOfMass;
};

// Namespace for fields that interacts with the core blob.
namespace core
{
	VehiblockData vehiblockData;

	VehiblockData@ getVehiblockData(CBlob@ core)
	{
		core.get(coreFieldData, vehiblockData);
		return vehiblockData;
	}

	void setVehiblockData(CBlob@ core)
	{
		core.set(coreFieldData, vehiblockData);
	}

	bool isBuildableAt(CBlob@ core, const Vec2f position)
	{
		return (position != Vec2f(0, 0));
	}

	Vec2f offsetFromWorldPos(CBlob@ blob, const Vec2f blockPosition)
	{
		const Vec2f blobPosition = blob.getPosition();
		const float tileSize = getMap().tilesize;
		Vec2f flat((blockPosition.x - blobPosition.x) / tileSize, (blockPosition.y - blobPosition.y) / tileSize);
		return flat.RotateBy(blob.getAngleDegrees());
	}

	CBlob@ addBlock(CBlob@ core, CBlob@ block, Vec2f position)
	{
		AttachmentPoint@ socket = core.getAttachments().AddAttachmentPoint(attachmentName, true),
						 plug = block.getAttachments().AddAttachmentPoint(attachmentName, false);
		socket.offset = position * 8.f;

		core.server_AttachTo(block, socket);

		return block;
	}

	void removeBlock(CBlob@ core, CBlob@ block)
	{
		AttachmentPoint@ coreAttachmentPoint = core.getAttachments().getAttachmentWithBlob(block);
		block.server_Die();
	}
}

namespace block
{
	CBlob@ getCore(CBlob@ block)
	{
		return block.getAttachments().getAttachedBlob(attachmentName);
	}
}

CBlob@ vehiblockCreateTile(CBlob@ core, const uint16 type)
{
	CBlob@ tile = server_CreateBlob(blockBlobName, core.getTeamNum(), Vec2f_zero);
	// TODO check if onInit happens immediately or if it happens afterwards
	/*CBitStream stream;
	stream.write_u16(type);

	tile.SendCommand(tile.getCommandID(blockInitCommandName), stream);*/
	return tile;
}
