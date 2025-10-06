import { prisma } from "../../utils/prisma";

export async function addDeliveryToQueue(userId: string, termId: string) {
  await prisma.delivery.create({
    data: { 
      userId, 
      termId, 
      deliveredAt: null // null = queued, not yet delivered
    },
  });
}

export async function getQueuedDeliveriesCount(userId: string): Promise<number> {
  return await prisma.delivery.count({
    where: { 
      userId, 
      deliveredAt: null 
    },
  });
}

export async function getNextQueuedDelivery(userId: string) {
  return await prisma.delivery.findFirst({
    where: { 
      userId, 
      deliveredAt: null 
    },
    include: { 
      term: { 
        include: { 
          topic: true 
        } 
      } 
    },
    orderBy: { 
      createdAt: "asc" 
    },
  });
}

export async function markDeliveryAsDelivered(deliveryId: string) {
  return await prisma.delivery.update({
    where: { id: deliveryId },
    data: { deliveredAt: new Date() }
  });
}
