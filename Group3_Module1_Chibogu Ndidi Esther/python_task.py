import cv2

img=cv2.imread('gift_card.jpg')

scale_percent=0.50
width = int(img.shape[1]*scale_percent)
height = int(img.shape[0]*scale_percent)
dimension = (width, height)

resized = cv2.resize(img, dimension, interpolation=cv2.INTER_AREA)

print(resized.shape)
cv2.imshow('output', resized)
cv2.imwrite('resized_giftcard.jpg', resized)

cv2.waitKey(0)
cv2.destroyAllWindows() 