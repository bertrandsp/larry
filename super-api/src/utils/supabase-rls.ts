import { PrismaClient } from '@prisma/client';

// Helper function to set user context for RLS
export async function withUserContext<T>(
  prisma: PrismaClient, 
  userId: string, 
  operation: () => Promise<T>
): Promise<T> {
  // Set the user context for RLS
  await prisma.$executeRaw`SELECT set_current_user_id(${userId})`;
  
  try {
    // Execute the operation
    const result = await operation();
    return result;
  } finally {
    // Clear the user context
    await prisma.$executeRaw`SELECT set_current_user_id(NULL)`;
  }
}

// Usage example:
// const userDeliveries = await withUserContext(prisma, userId, () =>
//   prisma.delivery.findMany({
//     where: { userId } // This will be enforced by RLS
//   })
// );
